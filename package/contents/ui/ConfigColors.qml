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

Kirigami.FormLayout {
property alias cfg_buttonColorize: buttonColorize.checked //type: Bool; label: Colorize task buttons; default: false
    property bool building: false
    //Props
    property color cfg_buttonActiveColor
    property color cfg_buttonInactiveColor
    property color cfg_buttonMinimizedColor
    property color cfg_buttonAttentionColor
    property color cfg_buttonProgressColor
    property color cfg_buttonHoverColor
    property color cfg_indicatorActiveColor
    property color cfg_indicatorInactiveColor
    property color cfg_indicatorMinimizedColor
    property color cfg_indicatorAttentionColor
    property color cfg_indicatorProgressColor //type: String; label: Set a custom color for the task button.; default: #00FF00
    property color cfg_indicatorHoverColor
    property color cfg_indicatorTailActiveColor
    property color cfg_indicatorTailInactiveColor
    property color cfg_indicatorTailMinimizedColor
    property color cfg_indicatorTailAttentionColor
    property color cfg_indicatorTailProgressColor
    property color cfg_indicatorTailHoverColor
    //Enable button colors
    property bool cfg_buttonActiveColorEnabled
    property bool cfg_buttonInactiveColorEnabled
    property bool cfg_buttonMinimizedColorEnabled
    property bool cfg_buttonAttentionColorEnabled
    property bool cfg_buttonProgressColorEnabled
    property bool cfg_buttonHoverColorEnabled
    //Auto Enabled
    property int cfg_buttonActiveColorAuto
    property int cfg_buttonInactiveColorAuto
    property int cfg_buttonMinimizedColorAuto
    property int cfg_buttonAttentionColorAuto
    property int cfg_buttonProgressColorAuto
    property int cfg_buttonHoverColorAuto
    property int cfg_indicatorActiveColorAuto
    property int cfg_indicatorInactiveColorAuto
    property int cfg_indicatorMinimizedColorAuto
    property int cfg_indicatorAttentionColorAuto
    property int cfg_indicatorProgressColorAuto
    property int cfg_indicatorHoverColorAuto
    property int cfg_indicatorTailActiveColorAuto
    property int cfg_indicatorTailInactiveColorAuto
    property int cfg_indicatorTailMinimizedColorAuto
    property int cfg_indicatorTailAttentionColorAuto
    property int cfg_indicatorTailProgressColorAuto
    property int cfg_indicatorTailHoverColorAuto
    //Auto methods
    property int cfg_buttonActiveColorMethod
    property int cfg_buttonInactiveColorMethod
    property int cfg_buttonMinimizedColorMethod
    property int cfg_buttonAttentionColorMethod
    property int cfg_buttonProgressColorMethod
    property int cfg_buttonHoverColorMethod
    property int cfg_indicatorActiveColorMethod
    property int cfg_indicatorInactiveColorMethod
    property int cfg_indicatorMinimizedColorMethod
    property int cfg_indicatorAttentionColorMethod
    property int cfg_indicatorProgressColorMethod
    property int cfg_indicatorHoverColorMethod
    property int cfg_indicatorTailActiveColorMethod
    property int cfg_indicatorTailInactiveColorMethod
    property int cfg_indicatorTailMinimizedColorMethod
    property int cfg_indicatorTailAttentionColorMethod
    property int cfg_indicatorTailProgressColorMethod
    property int cfg_indicatorTailHoverColorMethod
    //Tint intensity
    property int cfg_buttonActiveColorTint
    property int cfg_buttonInactiveColorTint
    property int cfg_buttonMinimizedColorTint
    property int cfg_buttonAttentionColorTint
    property int cfg_buttonProgressColorTint
    property int cfg_buttonHoverColorTint
    property int cfg_indicatorActiveColorTint
    property int cfg_indicatorInactiveColorTint
    property int cfg_indicatorMinimizedColorTint
    property int cfg_indicatorAttentionColorTint
    property int cfg_indicatorProgressColorTint
    property int cfg_indicatorHoverColorTint
    property int cfg_indicatorTailActiveColorTint
    property int cfg_indicatorTailInactiveColorTint
    property int cfg_indicatorTailMinimizedColorTint
    property int cfg_indicatorTailAttentionColorTint
    property int cfg_indicatorTailProgressColorTint
    property int cfg_indicatorTailHoverColorTint

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
                id: state
                model: [
                    {text: i18n("Active"), visible: true},
                    {text: i18n("Inactive"), visible: true},
                    {text: i18n("Minimized"), visible: true},
                    {text: i18n("Attention"), visible: true},
                    {text: i18n("Progress"), visible: !indicatorTailTab.checked},
                    {text: i18n("Hover"), visible: true}
                ]
                textRole: "text"
                delegate: ItemDelegate {
                    width: modelData.visible ? parent.width : 0
                    height: modelData.visible ? implicitHeight : 0
                    text: modelData.visible ? modelData.text : ""
                    font.weight: state.currentIndex === index ? Font.DemiBold : Font.Normal
                    highlighted: ListView.isCurrentItem
                    visible: modelData.visible
                }
            }
        }
        CheckBox{
            id: colorEnabled
            text: i18n("Coloring Enabled")
            visible: buttonTab.checked
        }
        ColorSlider {
            id: colorSelector
            enabled: (buttonColorize.checked && buttonTab.checked && colorEnabled.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
            }
    }
    Component.onCompleted: buildColorSlider()

    function buildCfgKey(){
        var cfgKey = "cfg_"
        if(buttonTab.checked) cfgKey += "button"
        else if(indicatorTab.checked) cfgKey += "indicator"
        else if(indicatorTailTab.checked) cfgKey += "indicatorTail"
        else return false
        switch(state.currentIndex){
            case 0:
                cfgKey += "Active"
                break;
            case 1:
                cfgKey += "Inactive"
                break;
            case 2:
                cfgKey += "Minimized"
                break;
            case 3:
                cfgKey += "Attention"
                break;
            case 4:
                cfgKey += "Progress"
                break;
            case 5:
                cfgKey += "Hover"
                break;
            case -1:
                return false
        }
        cfgKey += "Color"
        return cfgKey
    }

    function buildColorSlider(){
        colorForm.building = true
        var cfgKey = buildCfgKey()
        if(!cfgKey) return
        if(buttonTab.checked){
            colorSelector.colorType = "button"
            colorEnabled.checked = colorForm[cfgKey + "Enabled"]
        } 
        else if(indicatorTab.checked) colorSelector.colorType = "indicator"
        else if(indicatorTailTab.checked) colorSelector.colorType = "indicatorTail"
        switch(state.currentIndex){
            case 0:
                colorSelector.colorState = "Active"
                break;
            case 1:
                colorSelector.colorState = "Inactive"
                break;
            case 2:
                colorSelector.colorState = "Minimized"
                break;
            case 3:
                colorSelector.colorState = "Attention"
                break;
            case 4:
                colorSelector.colorState = "Progress"
                break;
            case 5:
                colorSelector.colorState = "Hover"
                break;
            default:
                colorSelector.colorState = "Active"
                break;
        }
        colorSelector.autoHue = colorForm[cfgKey + "Auto"] & 0b1 ? true : false
        colorSelector.autoSaturate = colorForm[cfgKey + "Auto"] & 0b10 ? true : false
        colorSelector.autoLightness = colorForm[cfgKey + "Auto"] & 0b100 ? true : false
        colorSelector.tintResult = colorForm[cfgKey + "Auto"] & 0b1000 ? true : false
        colorSelector.autoType = colorForm[cfgKey + "Method"]
        colorSelector.autoType = colorForm[cfgKey + "Tint"]
        colorSelector.color = colorForm[cfgKey]
        colorForm.building = false
    }

    function updateColors(){
        if(colorForm.building) return
        var cfgKey = buildCfgKey()
        if(!cfgKey) return
        var autoMethod = 0
        if(colorSelector.autoHue) autoMethod = autoMethod | 0b1
        if(colorSelector.autoSaturate) autoMethod = autoMethod | 0b10
        if(colorSelector.autoLightness) autoMethod = autoMethod | 0b100
        if(colorSelector.tintResult) autoMethod = autoMethod | 0b1000
        colorForm[cfgKey + "Auto"] = autoMethod
        colorForm[cfgKey] = colorSelector.color
        colorForm[cfgKey + "Method"] = colorSelector.autoType
        colorForm[cfgKey + "Tint"] = colorSelector.tintIntensity
        if(buttonTab.checked) colorForm[cfgKey + "Enabled"] = colorEnabled.checked
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
        target: colorSelector
        function onValueChanged(){
            updateColors()
        }
    }
    Connections {
        target: colorEnabled
        function onCheckedChanged(){
            updateColors()
        }
    }
}