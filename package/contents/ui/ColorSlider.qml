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
        colorPicker.updating = false
        colorSlider.valueChanged()
    }
    function autoColorPreview(){
        if(!colorSlider.autoHue && !colorSlider.autoSaturate && !colorSlider.autoLightness) return TaskTools.hexToHSL(colorPicker.color)
        switch(colorSlider.autoType){
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
        }
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
    property alias autoType: autoMethod.currentIndex

    property alias hue: hueComponent.value
    property alias saturation: satComponent.value
    property alias lightness: lightComponent.value
    property alias alpha: alphaComponent.value
    property alias color: colorPicker.color
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

        RowLayout{
            Label{
                text: i18n("Automatic color method:")
            }
            ComboBox {
                id: autoMethod
                enabled: colorSlider.autoHue || colorSlider.autoSaturate || colorSlider.autoLightness
                model: [
                    i18n("Average Icon Color"),
                    i18n("Background Icon Color"),
                    i18n("Closest to Black Icon Color"),
                    i18n("Closest to White Icon Color"),
                    i18n("Dominant Icon Color"),
                    i18n("Dominant Contrast Icon Color"),
                    i18n("Plasma Theme Accent Color")
                ]
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
            if(colorSlider.autoHue) var hexColor = autoColorPreview()
            else if(colorSlider.autoHue) var hexColor = TaskTools.hexToHSL(colorPicker.color)
            else return
            syncColors(hexColor)
        }
        function onAutoSaturateChanged(){
            if(colorPicker.updating) return
            if(colorSlider.autoSaturate) var hexColor = autoColorPreview()
            else if(colorSlider.autoSaturate) var hexColor = TaskTools.hexToHSL(colorPicker.color)
            else return
            syncColors(hexColor)
        }
        function onAutoLightnessChanged(){
            if(colorPicker.updating) return
            if(colorSlider.autoLightness) var hexColor = TaskTools.hexToHSL(colorPicker.color)
            else if(colorSlider.autoLightness) var hexColor = TaskTools.hexToHSL(colorPicker.color)
            else return
            syncColors(hexColor)
        }
    }
}
