Item {
    id: doubleSpinBox
    objectName: "DoubleSpinBox"
    SpinBox {
        property string label
        Kirigami.FormData.label: label

        property int decimals: 2
        property real realValue: value / 100

        validator: DoubleValidator {
            bottom: Math.min(indicatorGrowFactor.from, indicatorGrowFactor.to)
            top:  Math.max(indicatorGrowFactor.from, indicatorGrowFactor.to)
        }

        textFromValue: function(value, locale) {
            return Number(value / 100).toLocaleString(locale, 'f', indicatorGrowFactor.decimals)
        }

        valueFromText: function(text, locale) {
            return Number.fromLocaleString(locale, text) * 100
        }
    }
}
