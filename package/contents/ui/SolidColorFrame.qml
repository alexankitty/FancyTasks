import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore

import "code/tools.js" as TaskTools

Item {
    id: background

    Item {
        id: progress
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            fill: parent
        }

        width: parent.width

        Rectangle{
        id: colorFrame
        width: background.width
        height: background.height
        color: task.getColor()
        opacity: TaskTools.hexToHSL(task.buttonProperties.color).a
        }
    }
}
