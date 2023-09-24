import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import "../libconfig" as LibConfig
import "code/tools.js" as TaskTools

Item {
    function applyColors(hex){
        colorPicker.updating = true
        if(!colorSlider.autoHue) colorSlider.hue = hex.h * 359
        if(!colorSlider.autoSaturation) colorSlider.saturation = hex.s * 100
        if(!colorSlider.autoLightness) colorSlider.lightness = hex.l * 100
        colorSlider.alpha = hex.a * 100
        colorPicker.color = Qt.hsla(colorSlider.hue / 359, colorSlider.saturation/100, colorSlider.lightness/100, colorSlider.alpha/100) // Re-apply color in case it now differs
        colorPicker.updating = false
        colorSlider.valueChanged()
    }
    function iconColors(hex){
        colorPicker.updating = true
        if(colorSlider.autoHue) colorSlider.hue = hex.h * 359
        if(colorSlider.autoSaturation) colorSlider.saturation = hex.s * 100
        if(colorSlider.autoLightness) colorSlider.lightness = hex.l * 100
        colorPicker.color = Qt.hsla(colorSlider.hue / 359, colorSlider.saturation/100, colorSlider.lightness/100, colorSlider.alpha/100) // Re-apply color in case it now differs
        colorPicker.updating = false
        colorSlider.valueChanged()
    }
    function syncColors(hex){
        colorPicker.updating = true
        colorSlider.hue = hex.h * 359
        colorSlider.saturation = hex.s * 100
        colorSlider.lightness = hex.l * 100
        colorSlider.alpha = hex.a * 100
        colorPicker.color = Qt.hsla(colorSlider.hue / 359, colorSlider.saturation/100, colorSlider.lightness/100, colorSlider.alpha/100) // Re-apply color in case it now differs
        colorPicker.updating = false
        colorSlider.valueChanged()
    }
    function updateSliders(){
        colorPicker.updating = true
        colorPicker.color = Qt.hsla(colorSlider.hue / 359, colorSlider.saturation/100, colorSlider.lightness/100, colorSlider.alpha/100)
        if(colorSlider.tintResult) colorPicker.color = Kirigami.ColorUtils.tintWithAlpha(colorPicker.color, colorSlider.tintColor, tintIntensity / 100)
        colorPicker.updating = false
        colorSlider.valueChanged()
    }
    function autoColorPreview(){
        if(colorSlider.autoType == 7){
            if(colorForm["cfg_button" + colorSlider.colorState + "ColorAuto"]){
                auto = colorForm["cfg_button" + colorSlider.colorState + "ColorMethod"]
            } 
            else auto = 7
        }
        if(colorSlider.autoType == 8){
            if(colorForm["cfg_indicator" + colorSlider.colorState + "ColorAuto"]){
                auto = colorForm["cfg_indicator" + colorSlider.colorState + "ColorMethod"]
            } 
            else auto = 8
        }
        else{
            var auto = colorSlider.autoType
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
                var autoColor = colorForm["cfg_button" + colorSlider.colorState + "Color"]
                break;
            case 8:
                console.log(colorForm["cfg_indicator" + colorSlider.colorState + "Color"])
                var autoColor = colorForm["cfg_indicator" + colorSlider.colorState + "Color"]
                break;
            default:
                TaskTools.hexToHSL(colorPicker.color)
                break;
        }
        if(colorSlider.tintResult) autoColor = Kirigami.ColorUtils.tintWithAlpha(autoColor, colorSlider.tintColor, tintIntensity / 100)
        return TaskTools.hexToHSL(autoColor)
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
                model: [
                    {text: i18n("Average Icon Color"), visible: true},
                    {text: i18n("Background Icon Color"), visible: true},
                    {text: i18n("Closest to Black Icon Color"), visible: true},
                    {text: i18n("Closest to White Icon Color"), visible: true},
                    {text: i18n("Dominant Icon Color"), visible: true},
                    {text: i18n("Dominant Contrast Icon Color"), visible: true},
                    {text: i18n("Plasma Theme Accent Color"), visible: true},
                    {text: i18n("Button Color"), visible: colorSlider.colorType !== "button"},
                    {text: i18n("Indicator Color"), visible: colorSlider.colorType !== "indicator"}
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
                id: colorPicker
                showAlphaChannel: true
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                property bool updating: false //prevent a binding loop by not updating until we're done
            }
        }
    }
    Connections{
        target: hueComponent
        function onValueChanged(){
            if(colorPicker.updating) return
            updateSliders()
        }
    }
    Connections{
        target: satComponent
        function onValueChanged(){
            if(colorPicker.updating) return
            updateSliders()
        }
    }
    Connections{
        target: lightComponent
        function onValueChanged(){
            if(colorPicker.updating) return
            updateSliders()
        }
    }
    Connections{
        target: alphaComponent
        function onValueChanged(){
            if(colorPicker.updating) return
            updateSliders()
        }
    }
    Connections{
        target: tintComponent
        function onValueChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            syncColors(hexColor)
        }
    }
    Connections{
        target: colorPicker
        function onColorChanged(){
            if(colorPicker.updating) return
            var hexColor = TaskTools.hexToHSL(colorPicker.color)
            applyColors(hexColor)
        }
    }
    Connections{
        target: colorTest
        function onPaletteChanged() {
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            iconColors(hexColor)
        }
    }
    Connections{
        target: autoMethod
        function onCurrentIndexChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            iconColors(hexColor)
        }
    }
    Connections{
        target: colorSlider
        function onAutoHueChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            syncColors(hexColor)
        }
        function onAutoSaturateChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            syncColors(hexColor)
        }
        function onAutoLightnessChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            syncColors(hexColor)
        }
        function onTintResultChanged(){
            if(colorPicker.updating) return
            var hexColor = autoColorPreview()
            syncColors(hexColor)
        }
    }
}
