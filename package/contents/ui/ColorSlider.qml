import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kquickcontrols 2.0 as KQControls

import "../libconfig" as LibConfig

Item {
    id: colorSlider
    objectName: "ColorSlider"
    anchors.left: parent.left
    anchors.right: parent.right
    height: childrenRect.height
    width: childrenRect.width
    
    readonly property color color: "#FFFFFFFF"
    readonly property alias autoSaturate: sat.checked
    readonly property alias autoHue: hue.checked
    readonly property alias autoLightness: light.checked 
    readonly property alias autoType: autoMethod.currentValue

    readonly property alias hue: hue.value
    readonly property alias saturation: sat.value
    readonly property alias lightness: light.value
    readonly property alias alpha: alpha.value
    ColumnLayout{
        SliderComponent{
            label: "Hue"
            checkLabel: "Automatic"
            id: hue
            from: 0
            to: 360
            stepSize: 1.0
            decimals: 0
        }
        SliderComponent{
            label: "Saturation"
            checkLabel: "Automatic"
            id: sat
            from: 0
            to: 1.0
            stepSize: 1.0
            decimals: 2
        }
        SliderComponent{
            label: "Lightness"
            checkLabel: "Automatic"
            id: light
            from: 0
            to: 1.0
            stepSize: 1.0
            decimals: 2
        }
        SliderComponent{
            label: "Alpha"
            checkLabel: "Automatic"
            id: alpha
            from: 0
            to: 1.0
            stepSize: 1.0
            decimals: 2
        }

        RowLayout{
            Label {
                text: i18n("Color:")
            }
            KQControls.ColorButton {
                id: colorPicker
                showAlphaChannel: true
            }
        }

        RowLayout {
            Label {
                text: i18n("Icon Test:")
            }
            LibConfig.IconField {

            }
        }
        RowLayout{
            ComboBox {
                id: autoMethod
                model: [
                    i18n("Average"),
                    i18n("Background"),
                    i18n("Closest to Black"),
                    i18n("Closest to White"),
                    i18n("Dominant"),
                    i18n("Dominant Contrast")
                ]
            }
        }
    }
}
