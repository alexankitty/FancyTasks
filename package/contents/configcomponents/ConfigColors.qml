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
    property alias cfg_indicatorProgress: indicatorProgress.currentIndex

    property bool building: false
    property int ready: 0
    property string decorationType
    wideMode: false
    id: colorForm
    width: parent.width
    anchors.left: parent.left
    anchors.right: parent.right
    ColumnLayout{
        RowLayout{
            Label {
                text: i18n("Progress on:")
            }
            ComboBox {
                id: indicatorProgress
                model: [i18n("Frame"), i18n("Indicator"), i18n("Both")]
            }
        }
        LibConfig.StateComboBox {
            id: state
            showProgress: buttonTab.selectedIndex !== 2 && (cfg_indicatorProgress == 2 || cfg_indicatorProgress == 0 )
        }
        LibConfig.ButtonTabComponent{
            id: buttonTab
            showButtonColors: true
            indicatorCount: plasmoid.configuration.indicatorMaxLimit
        }
        Frame{
            ColumnLayout{
                ComboBox{
                    id: buttonColorize
                    model: [
                        i18n("Using Plasma Style/Accent"),
                        i18n("Using Color Overlay"),
                        i18n("Using Solid Color"),
                    ]
                }
                Label{
                    visible: !buttonColorize.currentIndex && !plasmoid.configuration.indicatorsEnabled
                    text: i18n("Enable Button Color Overlay or Indicators to be able to use this page.")
                }

                CheckBox{
                    id: colorEnabled
                    text: i18n("Coloring Enabled")
                    visible: buttonTab.selectedIndex == 0
                    enabled: (buttonColorize.currentIndex && buttonTab.selectedIndex == 0) || (buttonTab.selectedIndex == 1 && plasmoid.configuration.indicatorsEnabled) || (buttonTab.selectedIndex == 2 && plasmoid.configuration.indicatorsEnabled)
                }
                    LibConfig.ColorSlider {
                    id: colorSelector
                    enabled: (buttonColorize.currentIndex && buttonTab.selectedIndex == 0 && colorEnabled.checked) || (buttonTab.selectedIndex == 1 && plasmoid.configuration.indicatorsEnabled) || (buttonTab.selectedIndex == 2 && plasmoid.configuration.indicatorsEnabled)
                    colorState: state.displayText
                }
            }
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
        if(buttonTab.selectedIndex == 0) colorSelector.colorType = "button"
        else if(buttonTab.selectedIndex == 1) colorSelector.colorType = "indicator"
        else if(buttonTab.selectedIndex == 2) colorSelector.colorType = "indicatorTail"
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
        if(buttonTab.selectedIndex == 0) {
            buttonProperties.enabled = colorEnabled.checked
        }
        cfg_buttonProperties = buttonProperties.save(cfg_buttonProperties)
        cfg_buttonColorize = buttonColorize.currentIndex
    }

    Connections {
        target: buttonTab
        function onActivated() {
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