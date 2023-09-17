import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../libconfig" as LibConfig

Item{
    height: childrenRect.height
    width: childrenRect.width
    property alias configKey: spin.configKey
    property alias label: sliderLabel.text
    property alias checkLabel: check.text
    property alias decimals: spin.decimals
    property alias from: spin.minimumValue
    property alias to: spin.maximumValue
    property alias value: spin.valueReal
    property alias stepSize: spin.stepSize
    property alias checked: check.checked
    id: sliderComponent
    objectName: "SliderComponent"
    RowLayout{
        id: sliderLayout
        ColumnLayout{
            id: sliderComponentLabel
            Label{
                id: sliderLabel
                text: label
            }
            Slider {
                id: slider
                from: {
                    return sliderComponent.from
                }
                to: sliderComponent.to
            }
        }
        RowLayout{
            id: spinCheck
            LibConfig.SpinBox {
                id: spin
                decimals: 2
                minimumValue: 0.0
                maximumValue: 99.0
                stepSize: 1.0
            }
            CheckBox{
                id: check
                visible: !!text
            }
        }
    }
    Connections{
        target: slider
        function onValueChanged(){
            console.log(spin.minimumValue, spin.maximumValue)
            console.log(slider.value * spin.factor)
            console.log(spin.value, spin.valueReal, slider.value)
            spin.value = slider.value * spin.factor
        }
    }
}