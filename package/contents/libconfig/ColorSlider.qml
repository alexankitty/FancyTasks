import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import "../libconfig" as LibConfig
import "../ui/code/colortools.js" as ColorTools

ColumnLayout {
    function buildComponent(buttonProperties){
        console.log("Disabling color connectors.")
        toggleConnections(false)
        autoHue = buttonProperties.autoH
        autoSaturate = buttonProperties.autoS
        autoLightness = buttonProperties.autoL
        tintResult = buttonProperties.autoT
        autoType = buttonProperties.method
        tintIntensity = buttonProperties.tint
        color = buttonProperties.color
        syncColors(1, false)
        toggleConnections(true)
        console.log("Enabling color connectors.")
    }
    function syncColors(source = 0, sendValueChanged = true){
        //Source: 0: Automatic Checkbox 1: Color Picker 2: Color Slider
        console.log("syncing colors")
        colorPicker.updating = true
        let autoColor = autoColorPreview();
        if(source == 2) {var inputColor = Qt.hsla(colorSlider.hue / 359, colorSlider.saturation/100, colorSlider.lightness/100, colorSlider.alpha/100)}
        else {var inputColor = colorPicker.color}
        let autoBits = {
            h: autoHue,
            s: autoSaturate,
            l: autoLightness,
        }
        let alpha = ColorTools.hexToHSL(inputColor).a
        let mixedColor = ColorTools.mixColor(inputColor, autoColor, autoBits)
        let colorResult = ColorTools.hexToHSL(mixedColor)
        colorResult.a = alpha
        applyColors(colorResult, source, sendValueChanged)
        colorPicker.updating = false
    }
    function applyColors(hex, source = 0, sendValueChanged = true){
        console.log("applying colors")
        console.log(hex.a)
        if(source == 1 || source == 0){
            colorSlider.hue = hex.h * 359
            colorSlider.saturation = hex.s * 100
            colorSlider.lightness = hex.l * 100
            colorSlider.alpha = hex.a * 100
        }
        if(source == 2 || source == 0) colorPicker.color = Qt.hsla(hex.h, hex.s, hex.l, hex.a)
        let finalColor = hex
        let alpha = hex.a
        finalColor.a = 1
        if(tintResult) {
                let tintedColor = Kirigami.ColorUtils.tintWithAlpha(Qt.hsla(finalColor.h, finalColor.s, finalColor.l, finalColor.a), tintColor, tintIntensity / 100)
                finalColor  = ColorTools.hexToHSL(tintedColor)
            }
        finalColor.a = alpha
        colorPreview.color = Qt.hsla(finalColor.h, finalColor.s, finalColor.l, finalColor.a)
        if(sendValueChanged) colorSlider.valueChanged()
    }
    function autoColorPreview(){
        let buttonPropKey = 'button' + colorState
        let indicatorPropKey = 'indicator' + colorState
        var buttonProperties = new ColorTools.buttonProperties(cfg_buttonProperties, buttonPropKey)
        var indicatorProperties = new ColorTools.buttonProperties(cfg_buttonProperties, buttonPropKey)
        var auto = colorSlider.autoType
        if(colorSlider.autoType == 7){            
            if(buttonProperties.autoH || buttonProperties.autoS || buttonProperties.autoL || buttonProperties.autoT){
                var auto = buttonProperties.method
            } 
        }
        else if(colorSlider.autoType == 8){
            if(buttonProperties.autoH || buttonProperties.autoS || buttonProperties.autoL || buttonProperties.autoT){
                
                var auto = indicatorProperties.method
            } 
        }
        switch(auto){
            case 0:
                var autoColor = colorTest.averageColor
                break;
            case 1:
                var autoColor = colorTest.backgroundColor
                break;
            case 2:
                var autoColor = colorTest.closestToBlackColor
                break;
            case 3:
                var autoColor = colorTest.closestToWhiteColor
                break;
            case 4:
                var autoColor = colorTest.dominantColor
                break;
            case 5:
                var autoColor = colorTest.dominantContrastColor
                break;
            case 6:
                var autoColor = PlasmaCore.Theme.highlightColor
                break;
            case 7:
                var autoColor = buttonProperties.color
                break;
            case 8:
                var autoColor = indicatorProperties.color
                break;
            default:
                var autoColor = ColorTools.hexToHSL(colorPicker.color)
                break;
        }
        return autoColor
    }
    function toggleConnections(state) {
        hueConnector.enabled = state
        satConnector.enabled = state
        lightConnector.enabled = state
        alphaConnector.enabled = state
        tintConnector.enabled = state
        colorPickerConnector.enabled = state
        colorTestConnector.enabled = state
        autoMethodConnector.enabled = state
        colorSliderConnector.enabled = state
    }
    id: colorSlider
    objectName: "ColorSlider"
    height: childrenRect.height
    width: childrenRect.width
    signal valueChanged
    
    property alias autoHue: hueComponent.checked
    property alias autoSaturate: satComponent.checked
    property alias autoLightness: lightComponent.checked
    property alias tintResult: tintComponent.checked
    property alias autoType: autoMethod.currentIndex
    property string colorType
    property string colorState

    property alias hue: hueComponent.value
    property alias saturation: satComponent.value
    property alias lightness: lightComponent.value  
    property alias alpha: alphaComponent.value
    property alias tintIntensity: tintComponent.value
    property alias color: colorPicker.color
    property string tintColor: Kirigami.ColorUtils.brightnessForColor(PlasmaCore.Theme.backgroundColor) ===
                                Kirigami.ColorUtils.Dark ?
                                "#ffffff" : "#000000"
    ColumnLayout{
        Kirigami.ImageColors {
            id: colorTest
            source: iconTest.value
            property color averageColor: colorTest.average
            property color backgroundColor: colorTest.background
            property color closestToBlackColor: colorTest.closestToBlack
            property color closestToWhiteColor: colorTest.closestToWhite
            property color dominantColor: colorTest.dominant
            property color dominantContrastColor: colorTest.dominantContrast
            property bool firstColorChange: false
        }
        SliderComponent{
            label: i18n("Hue")
            checkLabel: i18n("Automatic")
            suffix: i18n("°")
            id: hueComponent
            from: 0
            to: 359
            stepSize: 1
            decimals: 0
        }
        SliderComponent{
            label: i18n("Saturation")
            checkLabel: i18n("Automatic")
            suffix: i18n("%")
            id: satComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
        }
        SliderComponent{
            label: i18n("Lightness")
            checkLabel: i18n("Automatic")
            suffix: i18n("%")
            id: lightComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
        }
        SliderComponent{
            label: i18n("Alpha")
            suffix: i18n("%")
            id: alphaComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
        }
        SliderComponent{
            label: i18n("Light/Dark Theme Tint Intensity")
            suffix: i18n("%")
            checkLabel: i18nc("Correct the resulting color based on if the user has a light or dark theme.", "Tint Result")
            id: tintComponent
            invertChecked: true
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
        }

        RowLayout{
            Label{
                text: i18n("Automatic color method:")
            }
            ComboBox {
                id: autoMethod
                enabled: colorSlider.autoHue || colorSlider.autoSaturate || colorSlider.autoLightness
                property int prevIndex
                model: [
                    {text: i18n("Average Icon Color"), visible: true, enabled: true},
                    {text: i18n("Background Icon Color"), visible: true, enabled: true},
                    {text: i18n("Closest to Black Icon Color"), visible: true, enabled: true},
                    {text: i18n("Closest to White Icon Color"), visible: true, enabled: true},
                    {text: i18n("Dominant Icon Color"), visible: true, enabled: true},
                    {text: i18n("Dominant Contrast Icon Color"), visible: true, enabled: true},
                    {text: i18n("Plasma Theme Accent Color"), visible: true, enabled: true},
                    {text: i18n("Button Color"), visible: colorSlider.colorType !== "button", enabled: colorSlider.colorType !== "button"},
                    {text: i18n("Indicator Color"), visible: colorSlider.colorType !== "indicator", enabled: colorSlider.colorType !== "indicator"}
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

        RowLayout {
            Label {
                id: iconTestLabel
                text: i18n("Icon Test:")
            }
            LibConfig.IconField {
                id: iconTest
            }
        }

        RowLayout{
            Label {
                text: i18n("Color:")
                Layout.leftMargin: iconTestLabel.width - width
            }
            KQControls.ColorButton {
                visible: false
                id: colorPicker
                showAlphaChannel: true
                property bool updating: false //prevent a binding loop by not updating until we're done
            }
            DummyColorButton {
                id: colorPreview
                showAlphaChannel: true
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                onClicked:{
                    colorPicker.clicked()
                }
            }
        }
    }
    Connections{
        id: hueConnector
        target: hueComponent
        function onValueChanged(){
            console.log("hue value changed")
            if(colorPicker.updating) return
            syncColors(2)
        }
    }
    Connections{
        id: satConnector
        target: satComponent
        function onValueChanged(){
            console.log("sat value changed")
            if(colorPicker.updating) return
            syncColors(2)
        }
    }
    Connections{
        id: lightConnector
        target: lightComponent
        function onValueChanged(){
            console.log("lightness value changed")
            if(colorPicker.updating) return
            syncColors(2)
        }
    }
    Connections{
        id: alphaConnector
        target: alphaComponent
        function onValueChanged(){
            console.log("alpha value changed")
            if(colorPicker.updating) return
            syncColors(2)
        }
    }
    Connections{
        id: tintConnector
        target: tintComponent
        function onValueChanged(){
            console.log("tint value changed")
            if(colorPicker.updating) return
            syncColors()
        }
    }
    Connections{
        id: colorPickerConnector
        target: colorPicker
        function onColorChanged(){
            console.log("color picker changed")
            if(colorPicker.updating) return
            syncColors(1)
        }
    }
    Connections{
        id: colorTestConnector
        target: colorTest
        function onPaletteChanged() {
            if(!colorTest.firstColorChange) {
                colorTest.firstColorChange = true
                return
            }
            console.log("icon palette changed")
            if(colorPicker.updating) return
            syncColors()
        }
    }
    Connections{
        id: autoMethodConnector
        target: autoMethod
        function onCurrentIndexChanged(){
            console.log("auto method changed")
            if(colorPicker.updating) return
            syncColors()
        }
    }
    Connections{
        id: colorSliderConnector
        target: colorSlider
        function onAutoHueChanged(){
            console.log("auto hue changed")
            if(colorPicker.updating) return
            syncColors()
        }
        function onAutoSaturateChanged(){
            console.log("auto saturate changed")
            if(colorPicker.updating) return
            syncColors()
        }
        function onAutoLightnessChanged(){
            console.log("auto lightness changed")
            if(colorPicker.updating) return
            syncColors()
        }
        function onTintResultChanged(){
            console.log("tinting changed")
            if(colorPicker.updating) return
            syncColors()
        }
    }
}