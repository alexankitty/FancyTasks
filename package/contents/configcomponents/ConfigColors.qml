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
import "../ui/code/colortools.js" as ColorTools

Kirigami.FormLayout {
    property alias cfg_buttonColorize: buttonColorize.currentIndex
    property var buttonProperties
    property var cfg_buttonProperties
    property bool building: false
    property int ready: 0
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
        ComboBox {
                property int prevIndex
                id: buttonColorize
                visible: buttonTab.checked
                model: [
                    {text: i18n("Using Plasma Style/Accent"), visible: true, enabled: true},
                    {text: i18n("Using Color Overlay"), visible: true, enabled: true},
                    {text: i18n("Using Solid Color"), visible: true, enabled: true},
                ]
                textRole: "text"
                delegate: ItemDelegate {
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
        Label{
            visible: !buttonColorize.currentIndex && !plasmoid.configuration.indicatorsEnabled
            text: i18n("Enable Button Color Overlay or Indicators to be able to use this page.")
        }
        RowLayout{
            Label{
                text: i18n("State")
            }
            ComboBox {
                enabled: (buttonColorize.currentIndex && buttonTab.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
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
            enabled: (buttonColorize.currentIndex && buttonTab.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
        }
        LibConfig.ColorSlider {
            id: colorSelector
            enabled: (buttonColorize.currentIndex && buttonTab.checked && colorEnabled.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
            colorState: state.displayText
            }
    }
    Component.onCompleted: {
        colorForm.building = true
        getProperties();
        buildColorSlider();
        colorSelectorConnector.enabled = true
        colorEnabledConnector.enabled = true
        colorForm.building = false
        }

    function getProperties(){
        if(!state.displayText) return
        let propKey = colorSelector.colorType + state.displayText
        buttonProperties = new ColorTools.buttonProperties(cfg_buttonProperties, propKey);
    }

    function buildColorSlider(){
        console.log("building")
        if(buttonTab.checked) colorSelector.colorType = "button"
        else if(indicatorTab.checked) colorSelector.colorType = "indicator"
        else if(indicatorTailTab.checked) colorSelector.colorType = "indicatorTail"
        colorEnabled.checked = buttonProperties.enabled
        colorSelector.autoHue = buttonProperties.autoH
        colorSelector.autoSaturate = buttonProperties.autoS
        colorSelector.autoLightness = buttonProperties.autoL
        colorSelector.tintResult = buttonProperties.autoT
        colorSelector.autoType = buttonProperties.method
        colorSelector.tintIntensity = buttonProperties.tint
        colorSelector.color = buttonProperties.color
    }

    function updateColors(){
        if(!buttonProperties) return
        
        buttonProperties.autoH = colorSelector.autoHue
        buttonProperties.autoS = colorSelector.autoSaturate
        buttonProperties.autoL = colorSelector.autoLightness
        buttonProperties.autoT = colorSelector.tintResult
        buttonProperties.color = colorSelector.color.toString()
        console.log(colorSelector.color)
        buttonProperties.method = colorSelector.autoType
        buttonProperties.tint = colorSelector.tintIntensity
        if(buttonTab.checked) {
            buttonProperties.enabled = colorEnabled.checked
        }
        cfg_buttonProperties = buttonProperties.save(cfg_buttonProperties)
        cfg_buttonColorize = buttonColorize.currentIndex
    }

    Connections {
        target: buttonTab
        function onCheckedChanged() {
            colorForm.building = true
            state.currentIndex = 0
            getProperties()
            buildColorSlider()
            colorForm.building = false
        }
    }
    Connections {
        target: indicatorTab
        function onCheckedChanged() {
            colorForm.building = true
            state.currentIndex = 0
            getProperties()
            buildColorSlider()
            colorForm.building = false
        }
    }
    Connections {
        target: indicatorTailTab
        function onCheckedChanged() {
            colorForm.building = true
            state.currentIndex = 0
            getProperties()
            buildColorSlider()
            colorForm.building = false
        }
    }
    Connections {
        target: state
        function onActivated(){
            colorForm.building = true
            getProperties()
            buildColorSlider()
            colorForm.building = false
        }
    }
    Connections {
        id: colorSelectorConnector
        target: colorSelector
        function onValueChanged(){
            if(colorForm.building) return
            if(colorForm.ready < 2){
                colorForm.ready++;
                return
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