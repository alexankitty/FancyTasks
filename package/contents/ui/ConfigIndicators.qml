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
    property alias cfg_groupIconEnabled: groupIconEnabled.currentIndex
    property alias cfg_disableInactiveIndicators: disableInactiveIndicators.checked
    property alias cfg_indicatorsAnimated: indicatorsAnimated.checked
    property alias cfg_indicatorLocation: indicatorLocation.currentIndex
    property alias cfg_indicatorReverse: indicatorReverse.checked
    property alias cfg_indicatorOverride: indicatorOverride.checked
    property alias cfg_indicatorStyle: indicatorStyle.currentIndex
    property alias cfg_indicatorMinLimit: indicatorMinLimit.value
    property alias cfg_indicatorMaxLimit: indicatorMaxLimit.value
    property alias cfg_indicatorDesaturate: indicatorDesaturate.checked
    property alias cfg_indicatorGrow: indicatorGrow.checked
    property alias cfg_indicatorGrowFactor: indicatorGrowFactor.value
    property alias cfg_indicatorSize: indicatorSize.value
    property alias cfg_indicatorLength: indicatorLength.value
    property alias cfg_indicatorRadius: indicatorRadius.value
    property alias cfg_indicatorShrink: indicatorShrink.value
    property alias cfg_indicatorDominantColor: indicatorDominantColor.checked
    property alias cfg_indicatorAccentColor:  indicatorAccentColor.checked
    property alias cfg_indicatorCustomColor: indicatorCustomColor.color 

    ComboBox {
        id: indicatorsEnabled
        Kirigami.FormData.label: i18n("Indicators:")
        model: [i18n("Disabled"), i18n("Enabled")]
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex
        visible: indicatorsEnabled.currentIndex
        id: disableInactiveIndicators
        text: i18n("Disable for Inactive Windows")
    }

    ComboBox {
        id: groupIconEnabled
        Kirigami.FormData.label: i18n("Group Overlay:")
        model: [i18n("Disabled"), i18n("Enabled")]
    }
    Label {
        text: i18n("Takes effect on next time plasma groups tasks.")
        font: Kirigami.Theme.smallFont
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorsAnimated
        Kirigami.FormData.label: i18n("Animate Indicators:")
        text: i18n("Enabled")
    }


    Item {
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex && !indicatorOverride.checked
        id: indicatorReverse
        Kirigami.FormData.label: i18n("Indicator Location:")
        text: i18n("Reverse shown side")
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorOverride
        text: i18n("Override location")
    }

    Label {
        text: i18n("Be sure to use this when using as a floating widget")
        font: Kirigami.Theme.smallFont
    }

    ComboBox {
        enabled: indicatorsEnabled.currentIndex
        visible: indicatorOverride.checked
        id: indicatorLocation
        model: [
            i18n("Bottom"),
            i18n("Left"),
            i18n("Right"),
            i18n("Top")
        ]
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    ComboBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorStyle
        Kirigami.FormData.label: i18n("Indicator Style:")
        Layout.fillWidth: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        model: [
            i18n("Metro"),
            i18n("Ciliora"),
            i18n("Dashes")
            ]
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorMinLimit
        Kirigami.FormData.label: i18n("Indicator Min Limit:")
        from: 0
        to: 10
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorMaxLimit
        Kirigami.FormData.label: i18n("Indicator Max Limit:")
        from: 1
        to: 10
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorDesaturate
        Kirigami.FormData.label: i18n("Minimize Options:")
        text: i18n("Desaturate")
    }

    CheckBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorGrow
        text: i18n("Shrink when minimized")
    }

    SpinBox {
        id: indicatorGrowFactor
        enabled: indicatorsEnabled.currentIndex
        visible: indicatorGrow.checked
        from: 100
        to: 10 * 100
        stepSize: 25
        Kirigami.FormData.label: i18n("Growth/Shrink factor:")

        property int decimals: 2
        property real realValue: value / 100

        validator: DoubleValidator {
            bottom: Math.min(indicatorGrowFactor.from, indicatorGrowFactor.to)
            top:  Math.max(indicatorGrowFactor.from, indicatorGrowFactor.to)
        }

        textFromValue: function(value, locale) {
            return Number(value / 100).toLocaleString(locale, 'f', indicatorGrowFactor.decimals)
        }

        valueFromText: function(text, locale) {
            return Number.fromLocaleString(locale, text) * 100
        }
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorSize
        Kirigami.FormData.label: i18n("Indicator size (px):")
        from: 1
        to: 999
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorLength
        Kirigami.FormData.label: i18n("Indicator length (px):")
        from: 1
        to: 999
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorRadius
        Kirigami.FormData.label: i18n("Indicator Radius (%):")
        from: 0
        to: 100
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorShrink
        Kirigami.FormData.label: i18n("Indicator margin (px):")
        from: 0
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
