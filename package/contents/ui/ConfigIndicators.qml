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

    property alias cfg_indicatorsEnabled: indicatorsEnabled.currentIndex //type: Int; label: Enable taskbar indicator effect. 0 = Off, 1 = On; default: 0
    property alias cfg_groupIconEnabled: groupIconEnabled.currentIndex //type: Int; label: Enable taskbar group overlay effect. 0 = Off, 1 = On; default: 1
    property alias cfg_indicatorProgress: indicatorProgress.checked //type: Bool; label: Display progress on indicator instead of button; default: false
    property alias cfg_indicatorProgressColor: indicatorProgressColor.color
    property alias cfg_disableInactiveIndicators: disableInactiveIndicators.checked //type: Bool; label: Disables the indicator for inactive windows; default: false
    property alias cfg_indicatorsAnimated: indicatorsAnimated.checked //type: Bool; label: Enable animating indicators; default: true
    property alias cfg_indicatorLocation: indicatorLocation.currentIndex //type: Int; label: Sets where the indicator should be. 0 = Top, 1 = Bottom, 2 = Left, 3 = Right; default: 0
    property alias cfg_indicatorReverse: indicatorReverse.checked //type: Bool; label: Reerse the side the indicator is shown on.; default: false
    property alias cfg_indicatorOverride: indicatorOverride.checked //type: Bool; label: Enable override the indicator's shown side.; default: false
    property alias cfg_indicatorEdgeOffset: indicatorEdgeOffset.value //type: Int; label: Sets how many pixels offset from the edge the indicator is; default: 0
    property alias cfg_indicatorStyle: indicatorStyle.currentIndex //type: Int; label: Select between 1 of 3 indicator styles. 0 = Metro, 1 = Cliora, 2 = Dots; default: 0
    property alias cfg_indicatorMinLimit: indicatorMinLimit.value //type: Int; label: Set the minimum number of running indicators to display.; default: 0
    property alias cfg_indicatorMaxLimit: indicatorMaxLimit.value //type: Int; label: Set the maximum number of running indicators to display.; default: 4
    property alias cfg_indicatorDesaturate: indicatorDesaturate.checked //type: Bool; label: Desaturate the indicator when minimized; default: false
    property alias cfg_indicatorGrow: indicatorGrow.checked //type: Bool; label: Shrink the indicator when minimized; default: false
    property alias cfg_indicatorGrowFactor: indicatorGrowFactor.value //type: Int; label: Amount to grow the indicator by; default: 100
    property alias cfg_indicatorSize: indicatorSize.value //type: Int; label: Set the size of the indicator in pixels; default: 4
    property alias cfg_indicatorLength: indicatorLength.value //type: Int; label: Set the length of the indicator in pixels; default: 8
    property alias cfg_indicatorRadius: indicatorRadius.value //type: Int; label: Set the roundness of the indicator in percentage; default: 0
    property alias cfg_indicatorShrink: indicatorShrink.value //type: Int; label: Set the indicator margins in pixels; default: 4
    property alias cfg_indicatorDominantColor: indicatorDominantColor.checked //type: Bool; label: Make the indicator the dominant Icon Color; default: false
    property alias cfg_indicatorAccentColor:  indicatorAccentColor.checked //type: Bool; label: Make the icon the plasma accent color.; default: true
    property alias cfg_indicatorCustomColor: indicatorCustomColor.color //type: String; label: Set the indicator to a custom color.; default: white

    ComboBox {
        id: indicatorsEnabled
        Kirigami.FormData.label: i18n("Indicators:")
        model: [i18n("Disabled"), i18n("Enabled")]
    }

    CheckBox {
        id: indicatorProgress
        enabled: indicatorsEnabled.currentIndex
        visible: indicatorsEnabled.currentIndex
        text: i18n("Display Progress on Indicator")
    }

    KQControls.ColorButton {
        enabled: indicatorsEnabled.currentIndex
        visible: indicatorProgress.checked
        id: indicatorProgressColor
        Kirigami.FormData.label: i18n("Progress Color:")
        showAlphaChannel: true
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

    Label {
        text: i18n("Be sure to use this when using as a floating widget")
        font: Kirigami.Theme.smallFont
    }

    SpinBox {
        enabled: indicatorsEnabled.currentIndex
        id: indicatorEdgeOffset
        Kirigami.FormData.label: i18n("Indicator Edge Offset (px):")
        from: 0
        to: 999
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
