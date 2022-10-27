import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // for DialogStatus
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.draganddrop 2.0
import org.kde.kirigami 2.20 as Kirigami

import QtGraphicalEffects 1.0


import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import "code/layout.js" as LayoutManager
import "code/tools.js" as TaskTools

Item{
    id: root
    readonly property int thickness: isVertical ? width - screenEdgeMargin : height - screenEdgeMargin
    readonly property int screenEdgeMargin: 0

    readonly property bool isHorizontal: plasmoid.formFactor === PlasmaCore.Types.Horizontal
    readonly property bool isVertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property bool isMetroStyle: plasmoid.configuration.indicatorStyle === 0
    readonly property bool isCilioraStyle: plasmoid.configuration.indicatorStyle === 1
    readonly property bool isDashesStyle: plasmoid.configuration.indicatorStyle === 2
    
    Rectangle{
        anchors.fill: parent
        color: white
        height: 20
        width: 20
    }
}

    /*GridLayout {
        id: boxesLayout
        anchors.topMargin: plasmoid.location === PlasmaCore.Types.TopEdge ? root.screenEdgeMargin : 0
        anchors.bottomMargin: plasmoid.location === PlasmaCore.Types.BottomEdge ? root.screenEdgeMargin : 0
        anchors.leftMargin: plasmoid.location === PlasmaCore.Types.LeftEdge ? root.screenEdgeMargin : 0
        anchors.rightMargin: plasmoid.location === PlasmaCore.Types.RightEdge ? root.screenEdgeMargin : 0

        width: isDashesStyle && isHorizontal ? undefined : (isHorizontal ? parent.width : undefined)
        height: isDashesStyle && isVertical ? undefined: (isVertical ? parent.height : undefined)

        rows: isHorizontal ? 1 : -1
        columns: isVertical ? 1 : -1

        rowSpacing: isVertical ? spacing : 0
        columnSpacing: isHorizontal ? spacing : 0

        readonly property int spacing: PlasmaCore.Units.gridUnit
        readonly property int thickness: plasmoid.configuration.indicatorSize

        readonly property int minLength: isCilioraStyle ? thickness : 2*thickness

            
        }

        Repeater {
            model: {
                //console.log(model)
                if (task.m.model.IsLauncher) {
                    return task.m.model.isActive ? 1 : 0
                }

                return Math.min(task.m.model.childCount, maxStates);
            }

            readonly property int maxStates: isMetroStyle ? 2 : 4

            Rectangle {
                id: stateRect

                Kirigami.ImageColors {
                    id: imageColors
                    source: task.m.model.decoration
                }
                Layout.fillWidth: isHorizontal && isFirst && !isDashesStyle
                Layout.fillHeight: isVertical && isFirst && !isDashesStyle

                Layout.minimumWidth: isHorizontal ? boxesLayout.minLength : boxesLayout.thickness
                Layout.maximumWidth: isHorizontal && isFirst ? -1 : (isHorizontal ? boxesLayout.minLength : boxesLayout.thickness)

                Layout.minimumHeight: isHorizontal ? boxesLayout.thickness : boxesLayout.minLength
                Layout.maximumHeight: isVertical && isFirst ? -1 : (isVertical ? boxesLayout.minLength : boxesLayout.thickness)

                color: white//!isFirst ? imagesColors.highlight : imageColors.dominant

                readonly property bool isFirst: index === 0
            }
        }

    /*states:[
        State {
            name: "bottom"
            when: plasmoid.configuration.indicatorLocation === 0

            AnchorChanges {
                target: boxesLayout
                anchors{ top:undefined; bottom:parent.bottom; left:parent.left; right:parent.right;
                    horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        },
        State {
            name: "left"
            when: plasmoid.configuration.indicatorLocation === 1

            AnchorChanges {
                target: boxesLayout
                anchors{ top:parent.top; bottom:parent.bottom; left:parent.left; right:undefined;
                    horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
        },
        State {
            name: "right"
            when: plasmoid.configuration.indicatorLocation === 2

            AnchorChanges {
                target: boxesLayout
                anchors{ top:parent.top; bottom:parent.left; left:undefined; right:parent.right;
                    horizontalCenter:undefined; verticalCenter:parent.verticalCenter}
            }
        },
        State {
            name: "top"
            when: plasmoid.configuration.indicatorLocation === 3

            AnchorChanges {
                target: boxesLayout
                anchors{ top:parent.top; bottom:undefined; left:parent.left; right:parent.right;
                    horizontalCenter:parent.horizontalCenter; verticalCenter:undefined}
            }
        }
    ]*/
}