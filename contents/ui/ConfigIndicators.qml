import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrols 2.0 as KQControls

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

Kirigami.FormLayout {
    anchors.left: parent.left
    anchors.right: parent.right

    property alias cfg_indicatorsEnabled: indicatorsEnabled.currentIndex
    property alias cfg_indicatorLocation: indicatorLocation.currentIndex
    property alias cfg_followIndicator: followIndicator.checked
    property alias cfg_usePlasmaStyle: usePlasmaStyle.currentIndex
    property alias cfg_indicatorStyle: indicatorStyle.currentIndex
    property alias cfg_indicatorSize: indicatorSize.value
    property alias cfg_indicatorDominantColor: indicatorDominantColor.checked
    property alias cfg_indicatorAccentColor:  indicatorAccentColor.checked
    property alias cfg_indicatorCustomColor: indicatorCustomColor.color 

    ComboBox {
        id: indicatorsEnabled
        Kirigami.FormData.label: i18n("Indicators:")
        model: [i18n("Disabled"), i18n("Enabled")]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        id: indicatorLocation
        Kirigami.FormData.label: i18n("Indicator Location:")
        model: [
            i18n("Top"),
            i18n("Bottom"),
            i18n("Left"),
            i18n("Right")
        ]
    }

    CheckBox {
        id: followIndicator
        Kirigami.FormData.label: i18n("Plasma Theme:")
        text: i18n("Follows indicator")
    }
    Label {
        visible: followIndicator.checked
        text: i18n("May appear backwards depending on the theme. Based on Breeze.")
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        enabled: indicatorsEnabled.currentIndex
        id: usePlasmaStyle
        Kirigami.FormData.label: i18n("Style:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        model: [i18n("Custom indicators only"), i18n("Use Plasma Style")]
    }

    ComboBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorStyle
        Kirigami.FormData.label: i18n("Indicator Style:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        model: [
            i18n("Metro"),
            i18n("Cliora"),
            i18n("Dashes")
            ]
    }

    Label {
        visible: usePlasmaStyle.currentIndex
        text: i18n("These settings may conflict with the existing plasma style")
        font: Kirigami.Theme.smallFont
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorSize
        Kirigami.FormData.label: i18n("Indicator size (px):")
        from: 1
        to: 999
    }


    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex & !indicatorAccentColor.checked
        id: indicatorDominantColor
        Kirigami.FormData.label: i18n("Indicator Color:")
        text: i18n("Use dominant icon color")
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex & !indicatorDominantColor.checked
        id: indicatorAccentColor
        text: i18n("Use plasma accent color")
    }

    KQControls.ColorButton {
        enabled: indicatorsEnabled.currentIndex & !indicatorDominantColor.checked & !indicatorAccentColor.checked
        id: indicatorCustomColor
        Kirigami.FormData.label: i18n("Custom Color:")
        showAlphaChannel: true
    }

    Item {
        Kirigami.FormData.isSection: true
    }
}