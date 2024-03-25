/*
    SPDX-FileCopyrightText: 2012-2016 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

.import QtQml 2.15 as QtQml
.import org.kde.taskmanager 0.1 as TaskManager
.import org.kde.plasma.core 2.0 as PlasmaCore // Needed by TaskManager

class buttonProperties {
    /* QML's implementation of ecmascript really does not like typing public variables in the class.
    color;
    enabled;
    autoH;
    autoS;
    autoL;
    autoT;
    method;
    tint;
    */
    constructor(color, enabled, auto, method, tint){
        this.color = color;
        this.enabled = enabled;
        this.autoH = auto & 0b1 ? true : false
        this.autoS = auto & 0b10 ? true : false
        this.autoL = auto & 0b100 ? true : false
        this.autoT = auto & 0b1000 ? true : false
        this.method = parseInt(method);
        this.tint = tint;
    }
}

function getButtonProperties(type, stringList){
    if(!stringList) return false;
    let accessorModifer = null;
    let properties = ['color', 'enabled', 'auto', 'method', 'tint']
    switch(type){
        case "Button":
            accessorModifer = 0;
            break;
        case "Indicator":
            accessorModifer = properties.length * 1;
            break;
        case "IndicatorTail":
            accessorModifer = properties.length * 2;
            break;
    }
    if(accessorModifer == null) return;
    let result = [];
    for(let x = 0; x < properties.length; x++){
        result.push(stringList[accessorModifer + x]);
    }
    return new buttonProperties(... result);
}

function setButtonProperties(type, object, stringList){
    if(!stringList) return false;
    let properties = ['color', 'enabled', 'auto', 'method', 'tint']
    let accessorModifer = null;
    switch(type){
        case "Button":
            accessorModifer = 0;
            break;
        case "Indicator":
            accessorModifer = properties.length * 1;
            break;
        case "IndicatorTail":
            accessorModifer = properties.length * 2;
            break;
    }
    if(accessorModifer == null) return;
    for(let x = 0; x < properties.length; x++){
        if(properties[x] == "auto"){
            let autoBits = (object.autoH << 0) | (object.autoS << 1) | (object.autoL << 2) | (object.autoT << 3);
            stringList[accessorModifer + x] = autoBits;
            continue;
        }
        stringList[accessorModifer + x] = object[properties[x]];
    }
    return stringList;
}

function wheelActivateNextPrevTask(anchor, wheelDelta, eventDelta) {
    // magic number 120 for common "one click"
    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
    wheelDelta += eventDelta;
    var increment = 0;
    while (wheelDelta >= 120) {
        wheelDelta -= 120;
        increment++;
    }
    while (wheelDelta <= -120) {
        wheelDelta += 120;
        increment--;
    }
    while (increment != 0) {
        activateNextPrevTask(anchor, increment < 0)
        increment += (increment < 0) ? 1 : -1;
    }

    return wheelDelta;
}

function activateNextPrevTask(anchor, next) {
    // FIXME TODO: Unnecessarily convoluted and costly; optimize.

    var taskIndexList = [];
    var activeTaskIndex = tasksModel.activeTask;

    for (var i = 0; i < taskList.children.length - 1; ++i) {
        var task = taskList.children[i];
        var modelIndex = task.modelIndex(i);

        if (task.m.IsLauncher !== true && task.m.IsStartup !== true) {
            if (task.m.IsGroupParent === true) {
                if (task == anchor) { // If the anchor is a group parent, collect only windows within the group.
                    taskIndexList = [];
                }

                for (var j = 0; j < tasksModel.rowCount(modelIndex); ++j) {
                    const childModelIndex = tasksModel.makeModelIndex(i, j);
                    const childHidden = tasksModel.data(childModelIndex, TaskManager.AbstractTasksModel.IsHidden);
                    if (!plasmoid.configuration.wheelSkipMinimized || !childHidden) {
                        taskIndexList.push(childModelIndex);
                    }
                }

                if (task == anchor) { // See above.
                    break;
                }
            } else {
                if (!plasmoid.configuration.wheelSkipMinimized || !task.m.IsHidden) {
                    taskIndexList.push(modelIndex);
                }
            }
        }
    }

    if (!taskIndexList.length) {
        return;
    }

    var target = taskIndexList[0];

    for (var i = 0; i < taskIndexList.length; ++i) {
        if (taskIndexList[i] === activeTaskIndex)
        {
            if (next && i < (taskIndexList.length - 1)) {
                target = taskIndexList[i + 1];
            } else if (!next) {
                if (i) {
                    target = taskIndexList[i - 1];
                } else {
                    target = taskIndexList[taskIndexList.length - 1];
                }
            }

            break;
        }
    }

    tasksModel.requestActivate(target);
}

function activateTask(index, model, modifiers, task) {
    if (modifiers & Qt.ShiftModifier) {
        tasksModel.requestNewInstance(index);
    } else if (model.IsGroupParent === true) {

        // Option 1 (default): Cycle through this group's tasks
        // ====================================================
        // If the grouped task does not include the currently active task, bring
        // forward the most recently used task in the group according to the
        // Stacking order.
        // Otherwise cycle through all tasks in the group without paying attention
        // to the stacking order, which otherwise would change with every click
        if (plasmoid.configuration.groupedTaskVisualization === 0) {
            let childTaskList = [];
            let highestStacking = -1;
            let lastUsedTask = undefined;

            // Build list of child tasks and get stacking order data for them
            for (let i = 0; i < tasksModel.rowCount(task.modelIndex(index)); ++i) {
                const childTaskModelIndex = tasksModel.makeModelIndex(task.itemIndex, i);
                childTaskList.push(childTaskModelIndex);
                const stacking = tasksModel.data(childTaskModelIndex, TaskManager.AbstractTasksModel.StackingOrder);
                if (stacking > highestStacking) {
                    highestStacking = stacking;
                    lastUsedTask = childTaskModelIndex;
                }
            }

            // If the active task is from a different app from the group that
            // was clicked on switch to the last-used task from that app.
            if (!childTaskList.some(index => tasksModel.data(index, TaskManager.AbstractTasksModel.IsActive))) {
                tasksModel.requestActivate(lastUsedTask);
            } else {
                // If the active task is already among in the group that was
                // activated, cycle through all tasks according to the order of
                // the immutable model index so the order doesn't change with
                // every click.
                for (let j = 0; j < childTaskList.length; ++j) {
                    const childTask = childTaskList[j];
                        if (tasksModel.data(childTask, TaskManager.AbstractTasksModel.IsActive)) {
                            // Found the current task. Activate the next one
                            let nextTask = j + 1;
                            if (nextTask >= childTaskList.length) {
                                nextTask = 0;
                            }
                            tasksModel.requestActivate(childTaskList[nextTask]);
                            break;
                        }
                }
            }
        }

        // Option 2: show tooltips for all child tasks
        // ===========================================
        // Make sure tooltips are actually enabled though; if not, fall through
        // to the next option.
        else if (plasmoid.configuration.showToolTips
            && plasmoid.configuration.groupedTaskVisualization === 1
        ) {
            if (tasks.toolTipOpenedByClick) {
                task.toolTipAreaItem.hideImmediately();
            } else {
                tasks.toolTipOpenedByClick = task;
                task.showToolTip();
                task.toolTipAreaItem.onContainsMouseChanged();
            }
        }

        // Option 3: show Window View for all child tasks
        // ==================================================
        // Make sure the Window View effect is  are actually enabled though;
        // if not, fall through to the next option.
        else if (backend.windowViewAvailable
            && (plasmoid.configuration.groupedTaskVisualization === 2
            || plasmoid.configuration.groupedTaskVisualization === 1)
        ) {
            task.hideToolTipTemporarily();
            tasks.activateWindowView(model.WinIdList);
        }

        // Option 4: show group dialog/textual list
        // ========================================
        // This is also the final fallback option if Tooltips or Present windows
        // are chosen but not actually available
        else {
            if (!!groupDialog) {
                task.hideToolTipTemporarily();
                groupDialog.visible = false;
            } else {
                createGroupDialog(task);
            }
        }
    } else {
        if (model.IsMinimized === true) {
            tasksModel.requestToggleMinimized(index);
            tasksModel.requestActivate(index);
        } else if (model.IsActive === true && plasmoid.configuration.minimizeActiveTaskOnClick) {
            tasksModel.requestToggleMinimized(index);
        } else {
            tasksModel.requestActivate(index);
        }
    }
}

function insertIndexAt(above, x, y) {
    if (above) {
        return above.itemIndex;
    } else {
        var distance = tasks.vertical ? x : y;
        var step = tasks.vertical ? LayoutManager.taskWidth() : LayoutManager.taskHeight();
        var stripe = Math.ceil(distance / step);

        if (stripe === LayoutManager.calculateStripes()) {
            return tasksModel.count - 1;
        } else {
            return stripe * LayoutManager.tasksPerStripe();
        }
    }
}

function publishIconGeometries(taskItems) {
    for (var i = 0; i < taskItems.length - 1; ++i) {
        var task = taskItems[i];

        if (task.IsLauncher !== true && task.m.IsStartup !== true) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.makeModelIndex(task.itemIndex),
                backend.globalRect(task), task);
        }
    }
}

function taskPrefix(prefix) {
    var effectivePrefix;
    switch (plasmoid.location) {
    case PlasmaCore.Types.LeftEdge:
        effectivePrefix = "west-" + prefix;
        break;
    case PlasmaCore.Types.TopEdge:
        effectivePrefix = "north-" + prefix;
        break;
    case PlasmaCore.Types.RightEdge:
        effectivePrefix = "east-" + prefix;
        break;
    default:
        effectivePrefix = "south-" + prefix;
    }
    if(plasmoid.configuration.overridePlasmaButtonDirection){
        switch (plasmoid.configuration.plasmaButtonDirection) {
            case 2:
                effectivePrefix = "west-" + prefix;
                break;
            case 1:
                effectivePrefix = "north-" + prefix;
                break;
            case 3:
                effectivePrefix = "east-" + prefix;
                break;
            default:
                effectivePrefix = "south-" + prefix;
            }
    }
    return [effectivePrefix, prefix];
}

function taskPrefixHovered(prefix) {
    var effectivePrefix = taskPrefix(prefix);

    if ("" !== prefix)
        effectivePrefix = [
            ...taskPrefix(prefix + "-hover"),
            ...taskPrefix("hover"),
            ...effectivePrefix
        ];

    return effectivePrefix;
}

function createGroupDialog(visualParent) {
    if (!visualParent) {
        return;
    }

    if (!!tasks.groupDialog) {
        tasks.groupDialog.visualParent = visualParent;
        return;
    }

    if (groupDialogComponent.status === QtQml.Component.Ready) {
        tasks.groupDialog = groupDialogComponent.createObject(tasks,
            {
                visualParent: visualParent,
            }
        );
    }
}

function hexToHSL(hex) {
    if(hex.toString().length == 9) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        var a = parseInt(result[1], 16);
        var r = parseInt(result[2], 16);
        var g = parseInt(result[3], 16);
        var b = parseInt(result[4], 16);
    }
    else{
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        var r = parseInt(result[1], 16);
        var g = parseInt(result[2], 16);
        var b = parseInt(result[3], 16);
        var a = 255;
    }
    r /= 255, g /= 255, b /= 255, a /= 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;
    if(max == min){
    h = s = 0; // achromatic
    }else{
    var d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch(max){
        case r: h = (g - b) / d + (g < b ? 6 : 0); break;
        case g: h = (b - r) / d + 2; break;
        case b: h = (r - g) / d + 4; break;
    }
    h /= 6;
}
var HSLA = new Object();
HSLA['h']=h;
HSLA['s']=s;
HSLA['l']=l;
HSLA['a']=a;
return HSLA;
}

