import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../libconfig" as LibConfig

Item{
    height: childrenRect.height
    width: childrenRect.width
    property alias configKey: spin.configKey
    property alias suffix: spin.suffix
    property alias label: sliderLabel.text
    property alias checkLabel: check.text
    property alias decimals: spin.decimals
    property alias from: spin.minimumValue
    property alias to: spin.maximumValue
    property alias internalValue: spin.valueReal
    property real value: internalValue
    property real changeValue: 0
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
                from: sliderComponent.from
                to: sliderComponent.to
                value: spin.valueReal
                enabled: !check.checked
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
                enabled: !check.checked
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
            spin.value = slider.value * spin.factor
            sliderComponent.value = spin.valueReal
        }
    }
    Connections{
        target: sliderComponent
        function onValueChanged(){
            spin.value = sliderComponent.value * spin.factor
        }
    }
}