/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrols 2.0 as KQControls


Kirigami.FormLayout {
    anchors.left: parent.left
    anchors.right: parent.right

    readonly property bool plasmaPaAvailable: Qt.createComponent("PulseAudio.qml").status === Component.Ready
    readonly property bool plasmoidVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool iconOnly: plasmoid.configuration.iconOnly

    property alias cfg_showToolTips: showToolTips.checked
    property alias cfg_highlightWindows: highlightWindows.checked
    property bool cfg_indicateAudioStreams
    property alias cfg_iconScale: iconScale.value
    property alias cfg_maxStripes: maxStripes.value
    property bool cfg_forceStripes
    property alias cfg_maxLength: maxLength.value
    property int cfg_iconSpacing: 0

    property alias cfg_useBorders: useBorders.checked
    property alias cfg_taskSpacingSize: taskSpacingSize.value

    property alias cfg_buttonColorize: buttonColorize.checked
    property alias cfg_buttonColorizeInactive: buttonColorizeInactive.checked
    property alias cfg_buttonColorizeDominant: buttonColorizeDominant.checked
    property alias cfg_buttonColorizeCustom: buttonColorizeCustom.color

    property alias cfg_disableButtonSvg: disableButtonSvg.checked
    property alias cfg_disableButtonInactiveSvg: disableButtonInactiveSvg.checked
    property alias cfg_overridePlasmaButtonDirection: overridePlasmaButtonDirection.checked
    property alias cfg_plasmaButtonDirection: plasmaButtonDirection.currentIndex

    CheckBox {
        id: showToolTips
        Kirigami.FormData.label: i18n("General:")
        text: i18n("Show tooltips")
    }

    RowLayout {
        // HACK: Workaround for Kirigami bug 434625
        // due to which a simple Layout.leftMargin on CheckBox doesn't work
        Item { implicitWidth: Kirigami.Units.gridUnit }
        CheckBox {
            id: highlightWindows
            text: i18n("Highlight windows when hovering over task tooltips")
            enabled: showToolTips.checked
        }
    }

    CheckBox {
        id: indicateAudioStreams
        text: i18n("Mark applications that play audio")
        checked: cfg_indicateAudioStreams && plasmaPaAvailable
        onCheckedChanged: cfg_indicateAudioStreams = checked
        enabled: plasmaPaAvailable
    }

    CheckBox {
        id: useBorders
        text: i18n("Use plasma borders")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    Slider {
        id: iconScale
        from: 0
        to: 300
        stepSize: 25.0
        Kirigami.FormData.label: i18n("Icon Scale") + " " + iconScale.valueAt(iconScale.position) + "%"
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ButtonGroup {
        id: colorizeButtonGroup
    }

    RadioButton {
        Kirigami.FormData.label: i18n("Button Colors:")
        checked: !buttonColorize.checked
        text: i18n("Using Plasma Style/Accent")
        ButtonGroup.group: colorizeButtonGroup
    }

    RadioButton {
        id: buttonColorize
        checked: plasmoid.configuration.buttonColorize === true
        text: i18n("Using Color Overlay")
        ButtonGroup.group: colorizeButtonGroup
    }

    CheckBox {
        enabled: buttonColorize.checked
        id: buttonColorizeDominant
        text: i18n("Use dominant icon color")
        visible: buttonColorize.checked
    }



    KQControls.ColorButton {
        Layout.leftMargin: Kirigami.Units.GridUnit
        enabled: buttonColorize.checked & !buttonColorizeDominant.checked
        id: buttonColorizeCustom
        Kirigami.FormData.label: i18n("Custom Color:")
        showAlphaChannel: true
        visible: buttonColorize.checked && !buttonColorizeDominant.checked
    }

    CheckBox {
        id: buttonColorizeInactive
        text: i18n("Colorize inactive buttons")
        visible: buttonColorize.checked
        enabled: !disableButtonInactiveSvg.checked
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: disableButtonSvg
        Kirigami.FormData.label: i18n("Plasma Button Decorations:")
        text: i18n("Disable All")
    }
    CheckBox {
        id: disableButtonInactiveSvg
        text: i18n("Disable Inactive Buttons")
        enabled: !disableButtonSvg.checked
    }

    CheckBox {
        id: overridePlasmaButtonDirection
        Kirigami.FormData.label: i18n("Plasma Button Direction:")
        text: i18n("Override")
    }

    Label {
        text: i18n("Be sure to use this when using as a floating widget")
        font: Kirigami.Theme.smallFont
    }

    ComboBox {
        id: plasmaButtonDirection
        visible: overridePlasmaButtonDirection.checked
        model: [
            i18n("North"),
            i18n("South"),
            i18n("West"),
            i18n("East")
        ]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    SpinBox {
        id: maxStripes
        Kirigami.FormData.label: plasmoidVertical ? i18n("Maximum columns:") : i18n("Maximum rows:")
        from: 1
    }

    CheckBox {//This setting defaults to on now when there is only 1 stripe because it makes no sense otherwise.
        id: forceStripes
        text: plasmoidVertical ? i18n("Always arrange tasks in rows of as many columns") : i18n("Always arrange tasks in columns of as many rows")
        enabled: maxStripes.value > 1
        checked: cfg_forceStripes || maxStripes.value === 1
        onCheckedChanged: cfg_forceStripes = checked
    }

    SpinBox {
        visible: !plasmoidVertical && !iconOnly
        id: maxLength
        Kirigami.FormData.label: i18n("Maximum button length (px):")
        from: 1
        to: 9999
    }

    SpinBox {
        id: taskSpacingSize
        Kirigami.FormData.label: i18n("Space between taskbar items (px):")
        from: 0
        to: 99
    }
    Label {
        text: i18n("Press OK to fix layout issues.")
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        visible: iconOnly
        Kirigami.FormData.label: i18n("Spacing between icons:")

        model: [
            {
                "label": i18nc("@item:inlistbox Icon spacing", "Small"),
                "spacing": 0
            },
            {
                "label": i18nc("@item:inlistbox Icon spacing", "Normal"),
                "spacing": 1
            },
            {
                "label": i18nc("@item:inlistbox Icon spacing", "Large"),
                "spacing": 3
            },
        ]

        textRole: "label"
        enabled: !Kirigami.Settings.tabletMode

        currentIndex: {
            if (Kirigami.Settings.tabletMode) {
                return 2; // Large
            }

            switch (cfg_iconSpacing) {
                case 0: return 0; // Small
                case 1: return 1; // Normal
                case 3: return 2; // Large
            }
        }
        onActivated: cfg_iconSpacing = model[currentIndex]["spacing"];
    }

    Label {
        visible: Kirigami.Settings.tabletMode
        text: i18nc("@info:usagetip under a set of radio buttons when Touch Mode is on", "Automatically set to Large when in Touch Mode")
        font: Kirigami.Theme.smallFont
    }
}
