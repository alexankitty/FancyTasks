import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import org.kde.kirigami 2.19 as Kirigami

import "../libconfig" as LibConfig

ColumnLayout {
    property alias aniDuration: indicatorAnimationDuration.value
    property alias location: indicatorLocation.currentIndex
    property alias align: indicatorAlignment.currentIndex
    property alias fill: indicatorFillAvailable.checked
    property alias unit: indicatorUnits.currentIndex
    property bool plasmoidVertical: false
    property real heightValue
    property real widthValue
    property real radius
    property var margins: [0,0,0,0]
    id: indicatorOptions
    objectName: "IndicatorOptions"
    signal valueChanged
    RowLayout{
        Label{
            text: i18n("Animation Duration (ms):")
        }
        SpinBox {
            id: indicatorAnimationDuration
            from: 0
            to: 5000
        }
    }
    RowLayout{
        Label{
            text: i18n("Indicator Location:")
        }
        ComboBox {
            id: indicatorLocation
            model: [
                i18n("Follow System"),
                i18n("Reverse System"),
                i18n("Bottom"),
                i18n("Left"),
                i18n("Right"),
                i18n("Top")
            ]
        }
    }

    RowLayout{
        Label{
            text: i18n("Align:")
        }
        ComboBox{
            id: indicatorAlignment
            model:[
                i18n("Left"),
                i18n("Center"),
                i18n("Right"),
            ]
        }
    }


    Item {
        Kirigami.FormData.isSection: true
    }
    RowLayout{
        Label {
            text: i18n("Fill Available Space:")
        }
        CheckBox {
            id: indicatorFillAvailable
        }
    }
    
    RowLayout{
        Label{
            text: i18n("Units:")
        }
        ComboBox {
            id: indicatorUnits
            model: [i18n("Pixels"), i18n("Percent")]
        }
    }
    

    ColumnLayout{
        visible: indicatorUnits.currentIndex == 0

        RowLayout{
            Label{
                text: i18n("Height (px):")
            }
            SpinBox {
                enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && !plasmoidVertical)
                id: indicatorHeightValue
                from: 1
                to: 999
                onValueChanged: {
                    heightValue = value
                }
            }
            
        }
        
        RowLayout{
            Label {
                text: i18n("Width (px):")
            }
            SpinBox {
                enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && plasmoidVertical)
                id: indicatorWidthValue
                from: 1
                to: 999
                onValueChanged: {
                    widthValue = value
                }
            }
            
        }

        RowLayout {
            Label {
                text: i18n("Corner Radius (px):")
            }
            SpinBox {
                id: indicatorCornerRadius
                from: 0
                to: 100
                onValueChanged: {
                    radius = value
                }
            }
        }
        RowLayout{
            Label{
                text: i18n("Margins (px):")
                height: parent.height
                Layout.fillHeight: true
                verticalAlignment: Text.AlignTop
            }
            RowLayout{
                ColumnLayout{
                    Label{
                        text: i18n("Top")
                    }
                    SpinBox {
                        id: indicatorMarginTop
                        from: 0
                        to: 999
                        onValueChanged: {
                            margins[0] = value
                        }
                    }
                    
                }
                ColumnLayout{
                    Label{
                        text: i18n("Left")
                    }
                    SpinBox {
                        id: indicatorMarginLeft
                        from: 0
                        to: 999
                        onValueChanged: {
                            margins[1] = value
                        }
                    }
                }
                ColumnLayout{
                    Label{
                        text: i18n("Right")
                    }
                    SpinBox {
                        id: indicatorMarginRight
                        from: 0
                        to: 999
                        onValueChanged: {
                            margins[2] = value
                        }
                    }
                }
                ColumnLayout{
                    Label{
                        text: i18n("Bottom")
                    }
                    SpinBox {
                        id: indicatorMarginBottom
                        from: 0
                        to: 999
                        onValueChanged: {
                            margins[3] = value
                        }
                    }
                }
            }
        }
    }

    ColumnLayout{
        visible: indicatorUnits.currentIndex == 1
        LibConfig.SliderComponent{
            enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && plasmoidVertical)
            label: i18n("Height")
            suffix: i18n("%")
            id: indicatorHeightValuePercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                heightValue = value
            }
        }
        LibConfig.SliderComponent{
            enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && !plasmoidVertical)
            label: i18n("Width")
            suffix: i18n("%")
            id: indicatorWidthValuePercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                widthValue = value
            }
        }
        LibConfig.SliderComponent{
            enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && !plasmoidVertical)
            label: i18n("Corner Radius")
            suffix: i18n("%")
            id: indicatorCornerRadiusPercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                radius = value
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Top")
            suffix: i18n("%")
            id: indicatorMarginTopPercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                margins[0] = value
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Left")
            suffix: i18n("%")
            id: indicatorMarginLeftPercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                margins[1] = value
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Right")
            suffix: i18n("%")
            id: indicatorMarginRightPercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                margins[2] = value
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Bottom")
            suffix: i18n("%")
            id: indicatorMarginBottomPercent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                margins[3] = value
            }
        }
    }
    function getKeys(){
        return {
            baseKey: 'indicator',
            valueKeys: [
                'HeightValue',
                'WidthValue',
                'Radius',
            ],
            destKeys: [
                'heightValue',
                'widthValue',
                'radius'
            ],
            marginKeys: [
                'Top',
                'Left',
                'Right',
                'Bottom'
            ]
        }
    }
    onMarginsChanged: {
        let keys = getKeys()
        let suffix = 'Percent'
        for(let key in keys.marginKeys){
            indicatorOptions[keys.baseKey + 'Margin' + keys.marginKeys[keys]] = indicatorOptions.margins[key]
            indicatorOptions[keys.baseKey + 'Margin' + keys.marginKeys[keys] + suffix] = indicatorOptions.margins[key]
        }
    }
    onHeightValueChanged: {
        indicatorOptions.indicatorHeightValue.value = heightValue
        indicatorOptions.indicatorHeightValuePercent.value = heightValue
    }
    onWidthValueChanged: {
        indicatorOptions.indicatorWidthValue.value = widthValue
        indcatoroptions.indicatorWidthValuePercent.value = widthValue
    }
    onRadiusChanged: {
        indicatorOptions.indicatorCornerRadius.value = radius
        indicatorOptions.indicatorCornerRadiusPercent.value = radius
    }   
}