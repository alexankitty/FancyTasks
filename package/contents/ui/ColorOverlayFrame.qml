import QtQuick 2.15

import org.kde.plasma.core 2.0 as PlasmaCore

import QtGraphicalEffects 1.15

import "code/colortools.js" as ColorTools

Item {
    id: background

    Item {
        id: overlayFrame
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            fill: parent
        }

        width: parent.width

        ColorOverlay {
            id: colorOverride
            source: frame
            width: background.width
            height: background.height
            color: getColor()
            opacity: ColorTools.hexToHSL(buttonProperties.color).a
        }
    }
}
