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
    property alias cfg_buttonColorize: buttonColorize.checked
    property bool building: false
    //Props
    property color cfg_buttonActiveColor
    property color cfg_buttonInctiveColor
    property color cfg_buttonMinimizedColor
    property color cfg_buttonAttentionColor
    property color cfg_buttonProgressColor
    property color cfg_buttonHoverColor
    property color cfg_indicatorActiveColor
    property color cfg_indicatorInctiveColor
    property color cfg_indicatorMinimizedColor
    property color cfg_indicatorAttentionColor
    property color cfg_indicatorProgressColor
    property color cfg_indicatorHoverColor
    property color cfg_indicatorTailActiveColor
    property color cfg_indicatorTailInctiveColor
    property color cfg_indicatorTailMinimizedColor
    property color cfg_indicatorTailAttentionColor
    property color cfg_indicatorTailProgressColor
    property color cfg_indicatorTailHoverColor
    //Auto Enabled
    property int cfg_buttonActiveColorAuto
    property int cfg_buttonInctiveColorAuto
    property int cfg_buttonMinimizedColorAuto
    property int cfg_buttonAttentionColorAuto
    property int cfg_buttonProgressColorAuto
    property int cfg_buttonHoverColorAuto
    property int cfg_indicatorActiveColorAuto
    property int cfg_indicatorInctiveColorAuto
    property int cfg_indicatorMinimizedColorAuto
    property int cfg_indicatorAttentionColorAuto
    property int cfg_indicatorProgressColorAuto
    property int cfg_indicatorHoverColorAuto
    property int cfg_indicatorTailActiveColorAuto
    property int cfg_indicatorTailInctiveColorAuto
    property int cfg_indicatorTailMinimizedColorAuto
    property int cfg_indicatorTailAttentionColorAuto
    property int cfg_indicatorTailProgressColorAuto
    property int cfg_indicatorTailHoverColorAuto
    //Auto methods
    property int cfg_buttonActiveColorMethod
    property int cfg_buttonInctiveColorMethod
    property int cfg_buttonMinimizedColorMethod
    property int cfg_buttonAttentionColorMethod
    property int cfg_buttonProgressColorMethod
    property int cfg_buttonHoverColorMethod
    property int cfg_indicatorActiveColorMethod
    property int cfg_indicatorInctiveColorMethod
    property int cfg_indicatorMinimizedColorMethod
    property int cfg_indicatorAttentionColorMethod
    property int cfg_indicatorProgressColorMethod
    property int cfg_indicatorHoverColorMethod
    property int cfg_indicatorTailActiveColorMethod
    property int cfg_indicatorTailInctiveColorMethod
    property int cfg_indicatorTailMinimizedColorMethod
    property int cfg_indicatorTailAttentionColorMethod
    property int cfg_indicatorTailProgressColorMethod
    property int cfg_indicatorTailHoverColorMethod

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
        ColorSlider {
            id: colorSelector
            enabled: (buttonColorize.checked && buttonTab.checked) || (indicatorTab.checked && plasmoid.configuration.indicatorsEnabled) || (indicatorTailTab.checked && plasmoid.configuration.indicatorsEnabled)
            }
    }
    Component.onCompleted: buildColorSlider()

    function buildCfgKey(){
        var cfgKey = "cfg_"
        if(buttonTab.checked)cfgKey += "button"
        else if(indicatorTab.checked) cfgKey += "indicator"
        else if(indicatorTailTab.checked) cfgKey += "indicatorTail"
        else return false
        switch(state.currentIndex){
            case 0:
                cfgKey += "Active"
                break;
            case 1:
                cfgKey += "Inctive"
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
        colorSelector.autoHue = colorForm[cfgKey + "Auto"] & 0b1 ? true : false
        colorSelector.autoSaturate = colorForm[cfgKey + "Auto"] & 0b10 ? true : false
        colorSelector.autoLightness = colorForm[cfgKey + "Auto"] & 0b100 ? true : false
        colorSelector.tintResult = colorForm[cfgKey + "Auto"] & 0b1000 ? true : false
        colorSelector.autoType = colorForm[cfgKey + "Method"]
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
    }

    Connections {
        target: buttonTab
        function onCheckedChanged() {
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
}