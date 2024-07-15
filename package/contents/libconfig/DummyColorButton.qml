/*
    SPDX-FileCopyrightText: 2015 David Edmundson <davidedmundson@kde.org>
 
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL

    Modified: 2024 Alexandra Stone <alexankitty@gmail.com>
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.3

import "../libconfig" as LibConfig

Button{
    objectName: "DummyColorButton"
    id: root
    
    property alias color: colorDialog.color
    property alias showAlphaChannel: root.showAlphaChannel

    property bool showAlphaChannel: true

    readonly property real _buttonMarigns: 4 // same as QStyles. Remove if we can get this provided by the QQC theme

    implicitWidth: 40 + _buttonMarigns * 2 // to perfectly clone kcolorbutton from kwidgetaddons

    Accessible.name: i18nc("@info:whatsthis for a button", "Color button")
    Accessible.description: enabled
    ? i18nc("@info:whatsthis for a button of current color code %1", "Current color is %1. This button will open a color chooser dialog.", color)
    : i18nc("@info:whatsthis for a button of current color code %1", "Current color is %1.", color)

    // create a checkerboard background for alpha to be adjusted
    Canvas {
        anchors.fill: colorBlock
        visible: colorDialog.color.a < 1

        onPaint: {
            const ctx = getContext('2d');

            ctx.fillStyle = "white";
            ctx.fillRect(0,0, ctx.width, ctx.height);

            ctx.fillStyle = "black";
            // in blocks of 16x16 draw two black squares of 8x8 in top left and bottom right
            for (let j = 0; j < width; j += 16) {
                for (let i = 0; i < height; i += 16) {
                    // top left, bottom right
                    ctx.fillRect(j, i, 8, 8);
                    ctx.fillRect(j + 8, i + 8, 8, 8);
                }
            }
        }
    }
    Rectangle {
        id: colorBlock

        anchors.centerIn: parent
        height: parent.height - root._buttonMarigns * 2
        width: parent.width - root._buttonMarigns * 2

        color: enabled ? colorDialog.color : disabledPalette.button

        SystemPalette {
            id: disabledPalette
            colorGroup: SystemPalette.Disabled
        }
    }

    ColorDialog {
        id: colorDialog
    }
}