/*
    SPDX-FileCopyrightText: 2012-2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // for DialogStatus
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.draganddrop 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import QtQuick.Layouts 1.3

import QtGraphicalEffects 1.15

import "code/layout.js" as LayoutManager
import "code/tools.js" as TaskTools

MouseArea {
    id: task

    activeFocusOnTab: true

    height: Math.max(theme.mSize(theme.defaultFont).height, PlasmaCore.Units.iconSizes.medium) + LayoutManager.verticalMargins()

    visible: false

    LayoutMirroring.enabled: (Qt.application.layoutDirection == Qt.RightToLeft)
    LayoutMirroring.childrenInherit: (Qt.application.layoutDirection == Qt.RightToLeft)

    readonly property var m: model
    
    readonly property int pid: model.AppPid !== undefined ? model.AppPid : 0
    readonly property string appName: model.AppName || ""
    readonly property variant winIdList: model.WinIdList
    property int itemIndex: index
    property bool inPopup: false
    property bool isWindow: model.IsWindow === true
    property int childCount: model.ChildCount !== undefined ? model.ChildCount : 0
    property int previousChildCount: 0
    property alias labelText: label.text
    property bool pressed: false
    property int pressX: -1
    property int pressY: -1
    property QtObject contextMenu: null
    property int wheelDelta: 0
    readonly property bool smartLauncherEnabled: !inPopup && model.IsStartup !== true
    property QtObject smartLauncherItem: null
    property alias toolTipAreaItem: toolTipArea
    property alias audioStreamIconLoaderItem: audioStreamIconLoader

    readonly property bool isMetro: plasmoid.configuration.indicatorStyle === 0
    readonly property bool isCiliora: plasmoid.configuration.indicatorStyle === 1
    readonly property bool isDashes: plasmoid.configuration.indicatorStyle === 2

    property Item audioStreamOverlay
    property var audioStreams: []
    property bool delayAudioStreamIndicator: false
    readonly property bool audioIndicatorsEnabled: plasmoid.configuration.indicateAudioStreams
    readonly property bool hasAudioStream: audioStreams.length > 0
    readonly property bool playingAudio: hasAudioStream && audioStreams.some(function (item) {
        return !item.corked
    })
    readonly property bool muted: hasAudioStream && audioStreams.every(function (item) {
        return item.muted
    })

    readonly property bool highlighted: (inPopup && activeFocus) || (!inPopup && containsMouse)
        || (task.contextMenu && task.contextMenu.status === PlasmaComponents.DialogStatus.Open)
        || (!!tasks.groupDialog && tasks.groupDialog.visualParent === task)

    property string tintColor: Kirigami.ColorUtils.brightnessForColor(PlasmaCore.Theme.backgroundColor) ===
                                Kirigami.ColorUtils.Dark ?
                                "#ffffff" : "#000000"

    Accessible.name: model.display
    Accessible.description: model.display ? i18n("Activate %1", model.display) : ""
    Accessible.role: Accessible.Button


    onHighlightedChanged: {
        // ensure it doesn't get stuck with a window highlighted
        backend.cancelHighlightWindows();
    }

    function showToolTip() {
        toolTipArea.showToolTip();
    }
    function hideToolTipTemporarily() {
        toolTipArea.hideToolTip();
    }

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton | Qt.BackButton | Qt.ForwardButton

    onPidChanged: updateAudioStreams({delay: false})
    onAppNameChanged: updateAudioStreams({delay: false})

    onIsWindowChanged: {
        if (isWindow) {
            taskInitComponent.createObject(task);
        }
    }

    onChildCountChanged: {
        if (childCount > previousChildCount) {
            tasksModel.requestPublishDelegateGeometry(modelIndex(), backend.globalRect(task), task);
        }

        previousChildCount = childCount;
    }

    onItemIndexChanged: {
        hideToolTipTemporarily();

        if (!inPopup && !tasks.vertical
            && (LayoutManager.calculateStripes() > 1 || !plasmoid.configuration.separateLaunchers)) {
            tasks.requestLayout();
        }
    }

    onContainsMouseChanged:  {
        if (containsMouse) {
            if (inPopup) {
                forceActiveFocus();
            }
        } else {
            pressed = false;
        }
    }

    onPressed: {
        if (mouse.button == Qt.LeftButton || mouse.button == Qt.MidButton || mouse.button === Qt.BackButton || mouse.button === Qt.ForwardButton) {
            pressed = true;
            pressX = mouse.x;
            pressY = mouse.y;
        } else if (mouse.button == Qt.RightButton) {
            // When we're a launcher, there's no window controls, so we can show all
            // places without the menu getting super huge.
            if (model.IsLauncher === true) {
                showContextMenu({showAllPlaces: true})
            } else {
                showContextMenu();
            }
        }
    }

    onPressAndHold: if (mouse.button === Qt.LeftButton) {
        /* TODO: make press and hold to open menu exclusive to touch.
         * I (ndavis) tried `if (lastDeviceType & ~(PointerDevice.Mouse | PointerDevice.TouchPad))`
         * with a TapHandler. lastDeviceType was gotten from the EventPoint argument of the
         * grabChanged() signal. ngraham said it wouldn't work because it was preventing single
         * taps on touch. I didn't have a touch screen to test it with.
         */
        // When we're a launcher, there's no window controls, so we can show all
        // places without the menu getting super huge.
        if (model.IsLauncher === true) {
            showContextMenu({showAllPlaces: true})
        } else {
            showContextMenu();
        }
    }

    onReleased: {
        if (pressed) {
            if (mouse.button == Qt.MidButton) {
                if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.NewInstance) {
                    tasksModel.requestNewInstance(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.Close) {
                    tasks.taskClosedWithMouseMiddleButton = winIdList.slice()
                    tasksModel.requestClose(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.ToggleMinimized) {
                    tasksModel.requestToggleMinimized(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.ToggleGrouping) {
                    tasksModel.requestToggleGrouping(modelIndex());
                } else if (plasmoid.configuration.middleClickAction === TaskManagerApplet.Backend.BringToCurrentDesktop) {
                    tasksModel.requestVirtualDesktops(modelIndex(), [virtualDesktopInfo.currentDesktop]);
                }
            } else if (mouse.button == Qt.LeftButton) {
                if (plasmoid.configuration.showToolTips && toolTipArea.active) {
                    hideToolTipTemporarily();
                }
                TaskTools.activateTask(modelIndex(), model, mouse.modifiers, task);
            } else if (mouse.button === Qt.BackButton || mouse.button === Qt.ForwardButton) {
                var sourceName = mpris2Source.sourceNameForLauncherUrl(model.LauncherUrlWithoutIcon, model.AppPid);
                if (sourceName) {
                    if (mouse.button === Qt.BackButton) {
                        mpris2Source.goPrevious(sourceName);
                    } else {
                        mpris2Source.goNext(sourceName);
                    }
                } else {
                    mouse.accepted = false;
                }
            }

            backend.cancelHighlightWindows();
        }

        pressed = false;
        pressX = -1;
        pressY = -1;
    }

    onPositionChanged: {
        // mouse.button is always 0 here, hence checking with mouse.buttons
        if (pressX != -1 && mouse.buttons == Qt.LeftButton && dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {
            tasks.dragSource = task;
            dragHelper.startDrag(task, model.MimeType, model.MimeData,
                model.LauncherUrlWithoutIcon, model.decoration);
            pressX = -1;
            pressY = -1;

            return;
        }
    }

    onWheel: {
        if (plasmoid.configuration.wheelEnabled && (!inPopup || !groupDialog.overflowing)) {
            wheelDelta = TaskTools.wheelActivateNextPrevTask(task, wheelDelta, wheel.angleDelta.y);
        } else {
            wheel.accepted = false;
        }
    }

    onSmartLauncherEnabledChanged: {
        if (smartLauncherEnabled && !smartLauncherItem) {
            const smartLauncher = Qt.createQmlObject(`
                import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet;

                TaskManagerApplet.SmartLauncherItem { }
            `, task);

            smartLauncher.launcherUrl = Qt.binding(() => model.LauncherUrlWithoutIcon);

            smartLauncherItem = smartLauncher;
        }
    }

    onHasAudioStreamChanged: {
        audioStreamIconLoader.active = hasAudioStream && audioIndicatorsEnabled;
    }

    onAudioIndicatorsEnabledChanged: {
        audioStreamIconLoader.active = hasAudioStream && audioIndicatorsEnabled;
    }

    function hexToHSL(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        let r = parseInt(result[1], 16);
        let g = parseInt(result[2], 16);
        let b = parseInt(result[3], 16);
        r /= 255, g /= 255, b /= 255;
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
    var HSL = new Object();
    HSL['h']=h;
    HSL['s']=s;
    HSL['l']=l;
    return HSL;
    }

    Keys.onReturnPressed: TaskTools.activateTask(modelIndex(), model, event.modifiers, task)
    Keys.onEnterPressed: Keys.onReturnPressed(event);
    Keys.onSpacePressed: Keys.onReturnPressed(event);

    function modelIndex() {
        return (inPopup ? tasksModel.makeModelIndex(groupDialog.visualParent.itemIndex, index)
            : tasksModel.makeModelIndex(index));
    }

    function showContextMenu(args) {
        toolTipArea.hideImmediately();
        contextMenu = tasks.createContextMenu(task, modelIndex(), args);
        contextMenu.show();
    }

    function updateAudioStreams(args) {
        if (args) {
            // When the task just appeared (e.g. virtual desktop switch), show the audio indicator
            // right away. Only when audio streams change during the lifetime of this task, delay
            // showing that to avoid distraction.
            delayAudioStreamIndicator = !!args.delay;
        }

        var pa = pulseAudio.item;
        if (!pa) {
            task.audioStreams = [];
            return;
        }

        var streams = pa.streamsForPid(task.pid);
        if (streams.length) {
            pa.registerPidMatch(task.appName);
        } else {
            // We only want to fall back to appName matching if we never managed to map
            // a PID to an audio stream window. Otherwise if you have two instances of
            // an application, one playing and the other not, it will look up appName
            // for the non-playing instance and erroneously show an indicator on both.
            if (!pa.hasPidMatch(task.appName)) {
                streams = pa.streamsForAppName(task.appName);
            }
        }

        task.audioStreams = streams;
    }

    function toggleMuted() {
        if (muted) {
            task.audioStreams.forEach(function (item) { item.unmute(); });
        } else {
            task.audioStreams.forEach(function (item) { item.mute(); });
        }
    }

    Connections {
        target: pulseAudio.item
        ignoreUnknownSignals: true // Plasma-PA might not be available
        function onStreamsChanged() {
            task.updateAudioStreams({delay: true})
        }
    }

    Component {
        id: taskInitComponent

        Timer {
            id: timer

            interval: PlasmaCore.Units.longDuration
            repeat: false

            onTriggered: {
                parent.hoverEnabled = true;

                if (parent.isWindow) {
                    tasksModel.requestPublishDelegateGeometry(parent.modelIndex(),
                        backend.globalRect(parent), parent);
                }

                timer.destroy();
            }

            Component.onCompleted: timer.start()
        }
    }

    PlasmaCore.FrameSvgItem {
        id: frame
        Kirigami.ImageColors {
            id: imageColors
            source: model.decoration
        }
        property color dominantColor: imageColors.dominant
        property color indicatorColor: Kirigami.ColorUtils.tintWithAlpha(frame.dominantColor, tintColor, .38)
        anchors {
            fill: parent

            topMargin: (!tasks.vertical && taskList.rows > 1) ? LayoutManager.iconMargin : 0
            bottomMargin: (!tasks.vertical && taskList.rows > 1) ? LayoutManager.iconMargin : 0
            leftMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? LayoutManager.iconMargin : 0
            rightMargin: ((inPopup || tasks.vertical) && taskList.columns > 1) ? LayoutManager.iconMargin : 0           
        }

        imagePath: plasmoid.configuration.disableButtonSvg ? "" : "widgets/tasks"
        enabledBorders: plasmoid.configuration.useBorders ? 1 | 2 | 4 | 8 : 0
        property bool isHovered: task.highlighted && plasmoid.configuration.taskHoverEffect
        property string basePrefix: "normal"
        prefix: isHovered ? TaskTools.taskPrefixHovered(basePrefix) : TaskTools.taskPrefix(basePrefix)
        visible: plasmoid.configuration.buttonColorize ? false : true
    }

    ColorOverlay {
        id: colorOverride
        anchors.fill: frame
        source: frame
        color: plasmoid.configuration.buttonColorizeDominant ?
                frame.indicatorColor :
                plasmoid.configuration.buttonColorizeCustom
        visible: plasmoid.configuration.buttonColorize ? true : false
    }

    Flow {
        id: indicator
        visible: plasmoid.configuration.indicatorsEnabled ? true : false
        flow: Flow.LeftToRight
        spacing: PlasmaCore.Units.smallSpacing
        clip: true
        Repeater {

            model: {
                
                if(!plasmoid.configuration.indicatorsEnabled)
                return 0;
                if(task.childCount < plasmoid.configuration.indicatorMinLimit)
                return 0;
                if(task.parent.toString().includes('QQuickItem'))//Target only the main task items.
                return 0;
                /*for(var key in task) {
                    console.log(key)
                    console.log(task[key])
                }*/ //Kept for debugging
                if(task.state === 'launcher') {
                    return 0;
                }
                return Math.min((task.childCount === 0) ? 1 : task.childCount, maxStates);
            }
            readonly property int maxStates: plasmoid.configuration.indicatorMaxLimit

            Rectangle{
                id: stateRect
                Behavior on height { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                Behavior on width { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                Behavior on color { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                Behavior on radius { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                readonly property color decoColor: frame.indicatorColor
                readonly property int maxStates: plasmoid.configuration.indicatorMaxLimit
                readonly property bool isFirst: index === 0
                readonly property int adjust: plasmoid.configuration.indicatorShrink
                readonly property int indicatorLength: plasmoid.configuration.indicatorLength
                readonly property int spacing: PlasmaCore.Units.smallSpacing
                readonly property bool isVertical: {
                    if(plasmoid.formFactor === PlasmaCore.Types.Vertical && !plasmoid.configuration.indicatorOverride)
                    return true;
                    if(plasmoid.formFactor == PlasmaCore.Types.Floating && plasmoid.configuration.indicatorOverride && (plasmoid.configuration.indicatorLocation === 1 || plasmoid.configuration.indicatorLocation === 2))
                    return  true;
                    if(plasmoid.configuration.indicatorOverride && (plasmoid.configuration.indicatorLocation === 1 || plasmoid.configuration.indicatorLocation === 2))
                    return  true;
                    else{
                        return false;
                    }
                }
                readonly property var computedVar: {
                    var height;
                    var width;
                    var colorCalc;
                    var colorEval = '#FFFFFF';
                    var parentSize = !isVertical ? frame.width : frame.height;
                    var indicatorComputedSize;
                    var adjustment = isFirst ? adjust : 0
                    var parentSpacingAdjust = task.childCount >= 1 && maxStates >= 2 ? (spacing * 2.5) : 0 //Spacing fix for multiple items
                    if(plasmoid.configuration.indicatorDominantColor){
                        colorEval = decoColor
                    }
                    if(plasmoid.configuration.indicatorAccentColor){
                        colorEval = PlasmaCore.Theme.highlightColor
                    }
                    else if(!plasmoid.configuration.indicatorDominantColor && !plasmoid.configuration.indicatorAccentColor){
                        colorEval = plasmoid.configuration.indicatorCustomColor
                    }
                    if(isFirst){//compute the size
                        var growFactor = plasmoid.configuration.indicatorGrowFactor / 100
                        if(plasmoid.configuration.indicatorGrow && task.state === "minimized") {
                            var mainSize = indicatorLength * growFactor;
                        }
                        else{
                            var mainSize = (parentSize + parentSpacingAdjust);
                        }
                        switch(plasmoid.configuration.indicatorStyle){
                            case 0:
                            indicatorComputedSize = mainSize - (Math.min(task.childCount, maxStates === 1 ? 0 : maxStates)  * (spacing + indicatorLength)) - adjust
                            break
                            case 1:
                            indicatorComputedSize = mainSize - (Math.min(task.childCount, maxStates === 1 ? 0 : maxStates)  * (spacing + indicatorLength)) - adjust
                            break
                            case 2:
                            indicatorComputedSize = plasmoid.configuration.indicatorGrow && task.state !== "minimized" ? indicatorLength * growFactor : indicatorLength
                            break
                            default:
                            break
                        }
                    }
                    else {
                        indicatorComputedSize = indicatorLength
                    }
                    if(!isVertical){
                        width = indicatorComputedSize;
                        height = plasmoid.configuration.indicatorSize
                    }
                    else{
                        width = plasmoid.configuration.indicatorSize
                        height = indicatorComputedSize
                    }
                    if(plasmoid.configuration.indicatorDesaturate && task.state === "minimizedNormal") {
                        var colorHSL = hexToHSL(colorEval)
                        colorCalc = Qt.hsla(colorHSL.h, colorHSL.s*0.5, colorHSL.l*.8, 1)
                    }
                    else if(!isFirst && plasmoid.configuration.indicatorStyle ===  0 && task.state !== "minimizedNormal") {//Metro specific handling
                        colorCalc = Qt.darker(colorEval, 1.2) 
                    }
                    else {
                        colorCalc = colorEval
                    }
                    return {height: height, width: width, colorCalc: colorCalc}
                }
                width: computedVar.width
                height: computedVar.height
                color: computedVar.colorCalc
                radius: (Math.max(width, height) / Math.min(width,  height)) * (plasmoid.configuration.indicatorRadius / 100)
                Rectangle{
                    Behavior on height { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                    Behavior on width { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                    Behavior on color { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                    Behavior on radius { PropertyAnimation {duration: plasmoid.configuration.indicatorsAnimated ? 250 : 0} }
                    visible:  task.isWindow && task.smartLauncherItem && task.smartLauncherItem.progressVisible && isFirst && plasmoid.configuration.indicatorProgress
                    anchors{
                        top: isVertical ? undefined : parent.top
                        bottom: isVertical ? undefined : parent.bottom
                        left: isVertical ? parent.left : undefined
                        right: isVertical ? parent.right : undefined
                    }
                    readonly property var progress: {
                        if(task.smartLauncherItem && task.smartLauncherItem.progressVisible && task.smartLauncherItem.progress){
                            return task.smartLauncherItem.progress / 100
                        }
                        return 0
                    }
                    width: isVertical ? parent.width : parent.width * progress
                    height: isVertical ? parent.height * progress : parent.height
                    radius: parent.radius
                    color: plasmoid.configuration.indicatorProgressColor
                }
            }   
        }
        
        states:[
            State {
                name: "bottom"
                when: (plasmoid.configuration.indicatorOverride && plasmoid.configuration.indicatorLocation === 0)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.BottomEdge && !plasmoid.configuration.indicatorReverse)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.TopEdge && plasmoid.configuration.indicatorReverse)
                    || (plasmoid.location === PlasmaCore.Types.Floating && plasmoid.configuration.indicatorLocation === 0)
                    || (plasmoid.location === PlasmaCore.Types.Floating && !plasmoid.configuration.indicatorOverride && !plasmoid.configuration.indicatorReverse)

                AnchorChanges {
                    target: indicator
                    anchors{ top:undefined; bottom:parent.bottom; left:undefined; right:undefined;
                        horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                    }
                PropertyChanges {
                    target: indicator
                    width: undefined
                    height: plasmoid.configuration.indicatorSize
                    anchors.topMargin: 0;
                    anchors.bottomMargin: plasmoid.configuration.indicatorEdgeOffset;
                    anchors.leftMargin: 0;
                    anchors.rightMargin: 0;
                }
            },
            State {
                name: "left"
                when: (plasmoid.configuration.indicatorOverride && plasmoid.configuration.indicatorLocation === 1)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.LeftEdge && !plasmoid.configuration.indicatorReverse)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.RightEdge && plasmoid.configuration.indicatorReverse)
                    || (plasmoid.location === PlasmaCore.Types.Floating && plasmoid.configuration.indicatorLocation === 1 && plasmoid.configuration.indicatorOverride)

                AnchorChanges {
                    target: indicator
                    anchors{ top:undefined; bottom:undefined; left:parent.left; right:undefined;
                        horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
                PropertyChanges {
                    target: indicator
                    height: undefined
                    width: plasmoid.configuration.indicatorSize
                    anchors.topMargin: 0;
                    anchors.bottomMargin: 0;
                    anchors.leftMargin: plasmoid.configuration.indicatorEdgeOffset;
                    anchors.rightMargin: 0;
                }
            },
            State {
                name: "right"
                when: (plasmoid.configuration.indicatorOverride && plasmoid.configuration.indicatorLocation === 2)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.RightEdge && !plasmoid.configuration.indicatorReverse)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.LeftEdge && plasmoid.configuration.indicatorReverse)
                    || (plasmoid.location === PlasmaCore.Types.Floating && plasmoid.configuration.indicatorLocation === 2 && plasmoid.configuration.indicatorOverride)

                AnchorChanges {
                    target: indicator
                    anchors{ top:undefined; bottom:undefined; left:undefined; right:parent.right;
                        horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
                }
                PropertyChanges {
                    target: indicator
                    height: undefined
                    width: plasmoid.configuration.indicatorSize
                    anchors.topMargin: 0;
                    anchors.bottomMargin: 0;
                    anchors.leftMargin: 0;
                    anchors.rightMargin: plasmoid.configuration.indicatorEdgeOffset;
                }
            },
            State {
                name: "top"
                when: (plasmoid.configuration.indicatorOverride && plasmoid.configuration.indicatorLocation === 3)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.TopEdge && !plasmoid.configuration.indicatorReverse)
                    || (!plasmoid.configuration.indicatorOverride && plasmoid.location === PlasmaCore.Types.BottomEdge && plasmoid.configuration.indicatorReverse)
                    || (plasmoid.location === PlasmaCore.Types.Floating && plasmoid.configuration.indicatorLocation === 3 && plasmoid.configuration.indicatorOverride)
                    || (plasmoid.location === PlasmaCore.Types.Floating && plasmoid.configuration.indicatorReverse && !plasmoid.configuration.indicatorOverride)

                AnchorChanges {
                    target: indicator
                    anchors{ top:parent.top; bottom:undefined; left:undefined; right:undefined;
                        horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
                }
                PropertyChanges {
                    target: indicator
                    width: undefined
                    height: plasmoid.configuration.indicatorSize
                    anchors.topMargin: plasmoid.configuration.indicatorEdgeOffset;
                    anchors.bottomMargin: 0;
                    anchors.leftMargin: 0;
                    anchors.rightMargin: 0;
                }
            }
        ]
    }

    PlasmaCore.ToolTipArea {
        id: toolTipArea

        anchors.fill: parent
        location: plasmoid.location

        enabled: plasmoid.configuration.showToolTips && !inPopup && !tasks.groupDialog && (tasks.toolTipOpenedByClick === task || tasks.toolTipOpenedByClick === null)
        interactive: model.IsWindow === true || mainItem.hasPlayer

        // when the mouse leaves the tooltip area, a timer to hide is set for (timeout / 20) ms
        // see plasma-framework/src/declarativeimports/core/tooltipdialog.cpp function dismiss()
        // to compensate for that we multiply by 20 here, to get an effective leave timeout of 2s.
        timeout: (tasks.toolTipOpenedByClick === task) ? 2000*20 : 4000

        mainItem: (model.IsWindow === true) ? openWindowToolTipDelegate : pinnedAppToolTipDelegate

        onToolTipVisibleChanged: {
            if (!toolTipVisible) {
                tasks.toolTipOpenedByClick = null;
            }
        }

        onContainsMouseChanged: if (containsMouse) {
            updateMainItemBindings();
        }

        // Will also be called in activateTaskAtIndex(index)
        function updateMainItemBindings() {
            if (tasks.toolTipOpenedByClick !== null && tasks.toolTipOpenedByClick !== task) {
                return;
            }

            mainItem.parentTask = task;
            mainItem.rootIndex = tasksModel.makeModelIndex(itemIndex, -1);

            mainItem.appName = Qt.binding(() => model.AppName);
            mainItem.pidParent = Qt.binding(() => model.AppPid !== undefined ? model.AppPid : 0);
            mainItem.windows = Qt.binding(() => model.WinIdList);
            mainItem.isGroup = Qt.binding(() => model.IsGroupParent === true);
            mainItem.icon = Qt.binding(() => model.decoration);
            mainItem.launcherUrl = Qt.binding(() => model.LauncherUrlWithoutIcon);
            mainItem.isLauncher = Qt.binding(() => model.IsLauncher === true);
            mainItem.isMinimizedParent = Qt.binding(() => model.IsMinimized === true);
            mainItem.displayParent = Qt.binding(() => model.display);
            mainItem.genericName = Qt.binding(() => model.GenericName);
            mainItem.virtualDesktopParent = Qt.binding(() =>
                (model.VirtualDesktops !== undefined && model.VirtualDesktops.length > 0) ? model.VirtualDesktops : [0]);
            mainItem.isOnAllVirtualDesktopsParent = Qt.binding(() => model.IsOnAllVirtualDesktops === true);
            mainItem.activitiesParent = Qt.binding(() => model.Activities);

            mainItem.smartLauncherCountVisible = Qt.binding(() => task.smartLauncherItem && task.smartLauncherItem.countVisible);
            mainItem.smartLauncherCount = Qt.binding(() => mainItem.smartLauncherCountVisible ? task.smartLauncherItem.count : 0);
        }
    }




    Loader {
        anchors.fill: frame
        asynchronous: true
        source: "TaskProgressOverlay.qml"
        active: task.isWindow && task.smartLauncherItem && task.smartLauncherItem.progressVisible && !plasmoid.configuration.indicatorProgress
    }

    Item {
        id: iconBox

        anchors {
            left: parent.left
            leftMargin: adjustMargin(true, parent.width, taskFrame.margins.left)
            top: parent.top
            topMargin: adjustMargin(false, parent.height, taskFrame.margins.top)
        }

        width: height * (plasmoid.configuration.iconScale / 100)
        height: (parent.height - adjustMargin(false, parent.height, taskFrame.margins.top)
            - adjustMargin(false, parent.height, taskFrame.margins.bottom))
        function adjustMargin(vert, size, margin) {
            if (!size) {
                return margin;
            }

            var margins = vert ? LayoutManager.horizontalMargins() : LayoutManager.verticalMargins();

            if ((size - margins) < PlasmaCore.Units.iconSizes.small) {
                return Math.ceil((margin * (PlasmaCore.Units.iconSizes.small / size)) / 2);
            }

            return margin;
        }

        //width: inPopup ? PlasmaCore.Units.iconSizes.small : Math.min(height, parent.width - LayoutManager.horizontalMargins())

        PlasmaCore.IconItem {
            id: icon
            active: task.highlighted
            anchors.centerIn: parent
            enabled: true
            usesPlasmaTheme: false
            roundToIconSize: false

            width: iconsOnly ? parent.width * (plasmoid.configuration.iconScale / 100) : parent.width
            height: width

            source: model.decoration
        }

        Loader {
            // QTBUG anchors.fill in conjunction with the Loader doesn't reliably work on creation:
            // have a window with a badge, move it from one screen to another, the new task item on the
            // other screen will now have a glitched out badge mask.
            width: icon.paintedWidth
            height: icon.paintedHeight
            anchors.centerIn: icon
            asynchronous: true
            source: "TaskBadgeOverlay.qml"
            active: height >= PlasmaCore.Units.iconSizes.small
                    && task.smartLauncherItem && task.smartLauncherItem.countVisible
        }

        states: [
            // Using a state transition avoids a binding loop between label.visible and
            // the text label margin, which derives from the icon width.
            State {
                name: "standalone"
                when: !label.visible

                AnchorChanges {
                    target: iconBox
                    anchors.left: undefined
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                PropertyChanges {
                    target: iconBox
                    anchors.leftMargin: 0
                    width: parent.width - adjustMargin(true, task.width, taskFrame.margins.left)
                                        - adjustMargin(true, task.width, taskFrame.margins.right)
                }
            }
        ]

        Loader {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
            active: model.IsStartup === true
            sourceComponent: busyIndicator
        }

        Component {
            id: busyIndicator
            PlasmaComponents3.BusyIndicator {}
        }
    }

    Loader {
        id: audioStreamIconLoader

        readonly property bool shown: item && item.visible
        readonly property var indicatorScale: 1.2

        source: "AudioStream.qml"
        width: Math.min(Math.min(iconBox.width, iconBox.height) * 0.4, PlasmaCore.Units.iconSizes.smallMedium)
        height: width

        Binding {
            target: audioStreamIconLoader.item
            property: "dominantIconColor"
            value: frame.indicatorColor
        }

        anchors {
            right: frame.right
            top: frame.top
            rightMargin: taskFrame.margins.right
            topMargin: Math.round(taskFrame.margins.top * indicatorScale)
        }
    }

    PlasmaComponents3.Label {
        id: label

        visible: (inPopup || !iconsOnly && model.IsLauncher !== true
            && (parent.width - iconBox.height - PlasmaCore.Units.smallSpacing) >= (theme.mSize(theme.defaultFont).width * LayoutManager.minimumMColumns()))

        anchors {
            fill: parent
            leftMargin: taskFrame.margins.left + iconBox.width + LayoutManager.labelMargin
            topMargin: taskFrame.margins.top
            rightMargin: taskFrame.margins.right + (audioStreamIconLoader.shown ? (audioStreamIconLoader.width + LayoutManager.labelMargin) : 0)
            bottomMargin: taskFrame.margins.bottom
        }

        wrapMode: (maximumLineCount == 1) ? Text.NoWrap : Text.Wrap
        elide: Text.ElideRight
        textFormat: Text.PlainText
        verticalAlignment: Text.AlignVCenter
        maximumLineCount: plasmoid.configuration.maxTextLines || undefined

        // use State to avoid unnecessary re-evaluation when the label is invisible
        states: State {
            name: "labelVisible"
            when: label.visible

            PropertyChanges {
                target: label
                text: model.display || ""
            }
        }
    }

    states: [
        State {
            name: "launcher"
            when: model.IsLauncher === true

            PropertyChanges {
                target: frame
                basePrefix: ""
            }
            PropertyChanges { 
                target: colorOverride
                visible: false
            }
        },
        State {
            name: "attention"
            when: model.IsDemandingAttention === true || (task.smartLauncherItem && task.smartLauncherItem.urgent)

            PropertyChanges {
                target: frame
                basePrefix: "attention"
            }
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.buttonColorize ? frame.isHovered ? true : false : false
            }
        },
        State {
            name: "minimizedNormal"
            when: model.IsMinimized === true && !frame.isHovered && !plasmoid.configuration.disableButtonInactiveSvg

            PropertyChanges {
                target: frame
                basePrefix: "minimized"
                visible: (plasmoid.configuration.buttonColorize && plasmoid.configuration.buttonColorizeInactive) ? false : true
            }
            PropertyChanges { 
                target: colorOverride
                visible: (plasmoid.configuration.buttonColorize && plasmoid.configuration.buttonColorizeInactive) ? true : false
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.disableInactiveIndicators ? false : true
            }
        },
        State {
            name: "minimizedNodecoration"
            when: (model.IsMinimized === true && !frame.isHovered) && plasmoid.configuration.disableButtonInactiveSvg

            PropertyChanges {
                target: frame
                basePrefix: "minimized"
                visible: plasmoid.configuration.disableButtonInactiveSvg ? false : true
            }
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.disableButtonInactiveSvg ? false : true
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.disableInactiveIndicators ? false : true
            }
        },
        State {
            name: "active"
            when: model.IsActive === true

            PropertyChanges {
                target: frame
                basePrefix: "focus"
            }
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.buttonColorize ? true : false
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.indicatorsEnabled ? true : false
            }
        },
        State {
            name: "inactiveNormal"
            when: model.IsActive === false && !frame.isHovered && !plasmoid.configuration.disableButtonInactiveSvg
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.buttonColorize && plasmoid.configuration.buttonColorizeInactive ? true : false
            }
            PropertyChanges { 
                target: frame
                visible: plasmoid.configuration.buttonColorize && plasmoid.configuration.buttonColorizeInactive ? false : true
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.disableInactiveIndicators ? false : true
            }
        },
        State {
            name: "inactiveNoDecoration"
            when: (model.IsActive === false && !frame.isHovered) && plasmoid.configuration.disableButtonInactiveSvg
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.disableButtonInactiveSvg ? false : true
            }
            PropertyChanges { 
                target: frame
                visible: plasmoid.configuration.disableButtonInactiveSvg ? false : true
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.disableInactiveIndicators ? false : true
            }
        },
        State {
            name: "hover"
            when: frame.isHovered
            PropertyChanges { 
                target: colorOverride
                visible: plasmoid.configuration.buttonColorize ? true : false
            }
            PropertyChanges { 
                target: frame
                visible: plasmoid.configuration.buttonColorize ? false : true
            }
            PropertyChanges{
                target: indicator
                visible: plasmoid.configuration.disableInactiveIndicators ? false : true
            }
        }
    ]

    Component.onCompleted: {
        if (!inPopup && model.IsWindow === true) {
            if(plasmoid.configuration.groupIconEnabled){
                var component = Qt.createComponent("GroupExpanderOverlay.qml");
                component.createObject(task);
            }
        }

        if (!inPopup && model.IsWindow !== true) {
            taskInitComponent.createObject(task);
        }

        updateAudioStreams({delay: false})
    }
}
