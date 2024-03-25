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


import "../libconfig" as LibConfig
import "../ui/code/tools.js" as TaskTools

Kirigami.FormLayout {
    property alias cfg_buttonColorize: buttonColorize.checked //type: Bool; label: Colorize task buttons; default: false
    property var cfg_buttonActiveProperties
    property var cfg_buttonInactiveProperties
    property var cfg_buttonMinimizedProperties
    property var cfg_buttonAttentionProperties
    property var cfg_buttonProgressProperties
    property var cfg_buttonHoverProperties
    property bool building: false
    property bool ready: false
    property string decorationType
    wideMode: false
    id: colorForm
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    ColumnLayout{
        TabBar{
            TabButton {
                id: buttonTab
                text: i18n("Button Colors")
            }
            TabButton {
                enabled: plasmoid.configuration.indicatorsEnabled
                id: indicatorTab
                text: i18n("Indicator Colors")
            }
            TabButton {
                enabled: plasmoid.configuration.indicatorsEnabled
                id: indicatorTailTab
                text: i18n("Indicator Tail Colors")
            }
        }
        ButtonGroup {
            id: colorizeButtonGroup
        }

        RadioButton {
            checked: !buttonColorize.checked
            text: i18n("Using Plasma Style/Accent")
            ButtonGroup.group: colorizeButtonGroup
            visible: buttonTab.checked
        }

        RadioButton {
            id: buttonColorize
            checked: plasmoid.configuration.buttonColorize === true
            text: i18n("Using Color Overlay")
            ButtonGroup.group: colorizeButtonGroup
            visible: buttonTab.checked
        }
        Label{
            visible: !buttonColorize.checked && !plasmoid.configuration.indicatorsEnabled
            text: i18n("Enable Button Color Overlay or Indicators to be able to use this page.")
        }
        RowLayout{
            Label{
                text: i18n("State")
            }
            ComboBox {
                enabled: (buttonColorize.checked && buttonTab.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
                currentIndex: 0
                property int prevIndex
                id: state
                model: [
                    {text: i18n("Active"), visible: true, enabled: true},
                    {text: i18n("Inactive"), visible: true, enabled: true},
                    {text: i18n("Minimized"), visible: true, enabled: true},
                    {text: i18n("Attention"), visible: true, enabled: true},
                    {text: i18n("Progress"), visible: !indicatorTailTab.checked, enabled: !indicatorTailTab.checked},
                    {text: i18n("Hover"), visible: true, enabled: true}
                ]
                textRole: "text"
                delegate: ItemDelegate {
                    id: stateDelegate
                    width: modelData.visible ? parent.width : 0
                    height: modelData.visible ? implicitHeight : 0
                    text: modelData.visible ? modelData.text : ""
                    font.weight: state.currentIndex === index ? Font.DemiBold : Font.Normal
                    highlighted: ListView.isCurrentItem
                    visible: modelData.visible
                    enabled: modelData.enabled
                }
                onActivated: {
                    if(!model[currentIndex].enabled){
                        if(currentIndex < count - 1 && prevIndex < currentIndex) currentIndex += 1
                        else currentIndex -= 1
                    }
                    prevIndex = currentIndex
                }
            }
        }
        CheckBox{
            id: colorEnabled
            text: i18n("Coloring Enabled")
            visible: buttonTab.checked
        }
        LibConfig.ColorSlider {
            id: colorSelector
            enabled: (buttonColorize.checked && buttonTab.checked && colorEnabled.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
            colorState: state.displayText
            }
    }
    Component.onCompleted: buildColorSlider()

    function buildCfgKey(){
        let cfgKey = "cfg_button"
        if(buttonTab.checked) colorForm.decorationType = "Button"
        else if(indicatorTab.checked) colorForm.decorationType = "Indicator"
        else if(indicatorTailTab.checked) colorForm.decorationType = "IndicatorTail"
        else return false
        cfgKey += state.displayText
        cfgKey += "Properties"
        return cfgKey
    }

    function buildColorSlider(){
        colorForm.building = true
        var cfgKey = buildCfgKey()
        if(!cfgKey) return
        var buttonProperties = TaskTools.getButtonProperties(colorForm.decorationType, colorForm[cfgKey]);
        if(buttonTab.checked) colorSelector.colorType = "button"
        else if(indicatorTab.checked) colorSelector.colorType = "indicator"
        else if(indicatorTailTab.checked) colorSelector.colorType = "indicatorTail"
        colorEnabled.checked = buttonProperties.enabled == 1 ? true : false
        colorSelector.autoHue = buttonProperties.autoH
        colorSelector.autoSaturate = buttonProperties.autoS
        colorSelector.autoLightness = buttonProperties.autoL
        colorSelector.tintResult = buttonProperties.autoT
        colorSelector.autoType = buttonProperties.method
        colorSelector.tintIntensity = buttonProperties.tint
        colorSelector.color = buttonProperties.color
        colorSelectorConnector.enabled = true
        colorEnabledConnector.enabled = true
        colorForm.building = false
    }

    function updateColors(){
        var cfgKey = buildCfgKey()
        if(!cfgKey) return
        var buttonProperties = TaskTools.getButtonProperties(colorForm.decorationType, colorForm[cfgKey]);
        if(!buttonProperties) return
        if(colorSelector.autoHue) buttonProperties.autoH = 1
        else buttonProperties.autoH = 0
        if(colorSelector.autoSaturate) buttonProperties.autoS = 1
        else buttonProperties.autoS = 0
        if(colorSelector.autoLightness) buttonProperties.autoL = 1
        else buttonProperties.autoL = 0
        if(colorSelector.tintResult) buttonProperties.autoT = 1
        else buttonProperties.autoT = 0
        buttonProperties.color = colorSelector.color
        buttonProperties.method = colorSelector.autoType
        buttonProperties.tint = colorSelector.tintIntensity
        if(buttonTab.checked) {
            if(colorEnabled.checked) buttonProperties.enabled = 1
            else buttonProperties.enabled = 0
        }
        colorForm[cfgKey] = TaskTools.setButtonProperties(colorForm.decorationType, buttonProperties, colorForm[cfgKey])
        plasmoid.configuration.buttonColorize == buttonColorize.checked
    }

    Connections {
        target: buttonTab
        function onCheckedChanged() {
            state.currentIndex = 0
            buildColorSlider()
        }
    }
    Connections {
        target: indicatorTab
        function onCheckedChanged() {
            state.currentIndex = 0
            buildColorSlider()
        }
    }
    Connections {
        target: indicatorTailTab
        function onCheckedChanged() {
            state.currentIndex = 0
            buildColorSlider()
        }
    }
    Connections {
        target: state
        function onActivated(){
            buildColorSlider()
        }
    }
    Connections {
        id: colorSelectorConnector
        target: colorSelector
        function onValueChanged(){
            if(colorForm.building) return
            //hack: prevents the first run of this to alleviate the race condition against the form builder
            if(!colorForm.ready) {
                colorForm.ready = true
                return;
            }
            updateColors()
        }
        enabled: false
    }
    Connections {
        id: colorEnabledConnector
        target: colorEnabled
        function onCheckedChanged(){
            if(colorForm.building) return
            updateColors()
        }
        enabled: false
    }
}