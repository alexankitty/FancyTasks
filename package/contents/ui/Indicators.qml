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
import "code/colortools.js" as ColorTools

Flow {
        id: indicator
        visible: ? true : false
        flow: Flow.LeftToRight
        spacing: PlasmaCore.Units.smallSpacing
        clip: true
        Repeater {

            model: {
                
                if(!plasmoid.configuration.indicatorsEnabled)
                return 0;
                if(task.childCount < plasmoid.configuration.indicatorMinLimit)
                return 0;
                if(task.isSubTask)//Target only the main task items.
                return 0;
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
                readonly property color decoColor: "#00000000"
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
                        var colorHSL = ColorTools.hexToHSL(colorEval)
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