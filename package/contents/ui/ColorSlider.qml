import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrols 2.0 as KQControls


Kirigami.FormLayout {
    id: colorSlider
    objectName: "ColorSlider"
    anchors.left: parent.left
    anchors.right: parent.right

    
    readonly property color color: "#FFFFFFFF"
    readonly property bool autoSaturate: false
    readonly property bool autoHue: false
    readonly property bool autoLightness: false 
    readonly property int autoType: 0

    readonly property int hue: hueSlider.valueAt(hueSlider.position)
    readonly property double saturation: satSlider.valueAt(satSlider.position)
    readonly property double lightness: lightSlider.valueAt(lightSlider.position)
    readonly property double alpha: alphaSlider.valueAt(alphaSlider.position)

    Label {
        text: i18n("Hue")
    }
    Slider {
        id: hueSlider
        from: 0
        to: 360
    }
    SpinBox {
        id: hueBox
        from: 0
        to: 360
        value: hue
    }
    Label {
        text: i18n("Saturation")
    }
    Slider {
        id: satSlider
        from: 0.0
        to: 1.0
    }
    MLDoubleSpinBox {
        id: satBox
        from: 0.0
        to: 1.0
        stepSize: 0.01
        value: saturation
    }
    Label {
        text: i18n("Lightness")
    }
    Slider {
        id: lightSlider
        from: 0
        to: 1
    }
    MLDoubleSpinBox {
        id: lightBox
        from: 0.0
        to: 1.0
        stepSize: 0.01
        value: lightness
    }
    Label {
        text: i18n("Alpha")
    }
    Slider {
        id: alphaSlider
        from: 0
        to: 1
        value: alpha
    }
    MLDoubleSpinBox {
        id: alphaBox
        from: 0.0
        to: 1.0
        stepSize: 0.01
    }
    KQControls.ColorButton {
        id: colorPicker
        showAlphaChannel: true
    }
    Label {
        text: i18n("Automatic Color Pick Method:")
    }
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
