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

    property alias cfg_showToolTips: showToolTips.checked //type: Bool; label: Whether to show tooltips when hovering task buttons.; default: true
    property alias cfg_highlightWindows: highlightWindows.checked //type: Bool; label: Whether to request the window manager highlight windows when hovering corresponding task tooltips.; default: true
    property bool cfg_indicateAudioStreams //type: Bool; label: Whether to indicate applications that are playing audio including an option to mute them.; default: true
    property alias cfg_iconScale: iconScale.value //type: Int; label: Scale of taskbar icons.; default: 100
    property alias cfg_iconSizePx: iconSizePx.value //type: Int; label: Size of taskbar icons in pixels.; default: 32
    property alias cfg_iconSizeOverride: iconSizeOverride.checked //type: Bool; label: Use icon size instead of scale.; default: false
    property alias cfg_maxStripes: maxStripes.value //type: Int; label: The maximum number of rows (in a horizontal-orientation containment, i.e. panel) or columns (in a vertical-orientation containment) to layout task buttons in.; default: 2
    property bool cfg_forceStripes //type: Bool; label: Whether to try and always layout task buttons in as many rows/columns as set via maxStripes.; default: false
    property alias cfg_maxButtonLength: maxButtonLength.value //type: Int; label: The max legnth of a task button.; default: 200
    property int cfg_iconSpacing: 0 //type: Int; label:  Spacing between icons in task manager. Margin is multiplied by this value.; default: 1

    property alias cfg_useBorders: useBorders.checked //type: Bool; label: Enable plasma borders.; default: True
    property alias cfg_taskSpacingSize: taskSpacingSize.value //type: Int; label: Size in pixels of space between taskbar items.; default: 0

    property alias cfg_plasmaButtonDirection: plasmaButtonDirection.currentIndex //type: Int; label: Direction of the plasma button SVG: 0 = North, 1 = West, 2 = South, 3 = East; default: 0

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
        enabled: plasmoid.configuration.buttonColorize != 2;
    }

    Label {
        visible: !useBorders.enabled
        text: i18n("Can't be changed when Button Colors are set to Using Solid Color.")
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    Slider {
        id: iconScale
        from: 0
        to: 300
        stepSize: 25
        Kirigami.FormData.label: i18n("Icon Scale") + " " + iconScale.valueAt(iconScale.position) + "%"
        visible: !iconSizeOverride.checked
    }

    SpinBox {
        id: iconSizePx
        Kirigami.FormData.label: i18n("Icon Size (px):")
        from: 0
        to: 999
        visible: iconSizeOverride.checked
    }

    CheckBox {
        id: iconSizeOverride
        text: i18n("Set icon size instead of scaling")
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: plasmaButtonDirection
        model: [
            i18n("Follow System"),
            i18n("Reverse System"),
            i18n("Bottom"),
            i18n("Left"),
            i18n("Right"),
            i18n("Top")
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
        id: maxButtonLength
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
