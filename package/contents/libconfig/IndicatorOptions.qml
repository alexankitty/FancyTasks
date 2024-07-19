import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import org.kde.kirigami 2.19 as Kirigami

import "../libconfig" as LibConfig

ColumnLayout {
    property bool plasmoidVertical: false

    property var valueArr: {return new Object()}

    property alias location: locationComponent.currentIndex

    property bool inserting: false
    property bool ready: false

    id: indicatorOptions
    objectName: "IndicatorOptions"
    signal valueChanged

    RowLayout{
        Label{
            text: i18n("Animation Duration (ms):")
        }
        SpinBox {
            id: animationDurationComponent
            from: 0
            to: 5000
            onValueChanged: {
                valueArr['aniDuration'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
    }
    RowLayout{
        Label{
            text: i18n("Indicator Location:")
        }
        ComboBox {
            id: locationComponent
            model: [
                i18n("Follow System"),
                i18n("Reverse System"),
                i18n("Bottom"),
                i18n("Left"),
                i18n("Right"),
                i18n("Top")
            ]
            onCurrentIndexChanged: {
                valueArr['location'] = currentIndex
                indicatorOptions.sendValueChangedSignal()
            }
        }
    }

    RowLayout{
        Label{
            text: i18n("Align:")
        }
        ComboBox{
            id: alignComponent
            model:[
                i18n("Left"),
                i18n("Center"),
                i18n("Right"),
            ]
            onCurrentIndexChanged: {
                valueArr['align'] = currentIndex
                indicatorOptions.sendValueChangedSignal()
            }
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
            id: fillComponent
            onCheckedChanged: {
                valueArr['fill'] = checked
                indicatorOptions.sendValueChangedSignal()
            }
        }
    }
    
    RowLayout{
        Label{
            text: i18n("Units:")
        }
        ComboBox {
            id: unitComponent
            model: [i18n("Pixels"), i18n("Percent")]
            onCurrentIndexChanged: {
                valueArr['unit'] = currentIndex
                indicatorOptions.sendValueChangedSignal()
            }
        }
    }
    

    ColumnLayout{
        visible: unitComponent.currentIndex == 0

        RowLayout{
            Label{
                text: i18n("Height (px):")
            }
            SpinBox {
                enabled: !fillComponent.checked || (fillComponent.checked && !plasmoidVertical)
                id: heightComponent
                from: 0
                to: 999
                onValueChanged: {
                    valueArr['height'] = value
                    indicatorOptions.sendValueChangedSignal()
                }
            }
            
        }
        
        RowLayout{
            Label {
                text: i18n("Width (px):")
            }
            SpinBox {
                enabled: !fillComponent.checked || (fillComponent.checked && plasmoidVertical)
                id: widthComponent
                from: 0
                to: 999
                onValueChanged: {
                    valueArr['width'] = value
                    indicatorOptions.sendValueChangedSignal()
                }
            }
            
        }

        RowLayout {
            Label {
                text: i18n("Corner Radius (px):")
            }
            SpinBox {
                id: radiusComponent
                from: 0
                to: 100
                onValueChanged: {
                    valueArr['radius'] = value
                    indicatorOptions.sendValueChangedSignal()
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
                        id: marginTopComponent
                        from: 0
                        to: 999
                        onValueChanged: {
                            valueArr['margins']['top'] = value
                            indicatorOptions.sendValueChangedSignal()
                        }
                    }
                    
                }
                ColumnLayout{
                    Label{
                        text: i18n("Left")
                    }
                    SpinBox {
                        id: marginLeftComponent
                        from: 0
                        to: 999
                        onValueChanged: {
                            valueArr['margins']['left'] = value
                            indicatorOptions.sendValueChangedSignal()
                        }
                    }
                }
                ColumnLayout{
                    Label{
                        text: i18n("Right")
                    }
                    SpinBox {
                        id: marginRightComponent
                        from: 0
                        to: 999
                        onValueChanged: {
                            valueArr['margins']['right'] = value
                            indicatorOptions.sendValueChangedSignal()
                        }
                    }
                }
                ColumnLayout{
                    Label{
                        text: i18n("Bottom")
                    }
                    SpinBox {
                        id: marginBottomComponent
                        from: 0
                        to: 999
                        onValueChanged: {
                            valueArr['margins']['bottom'] = value
                            indicatorOptions.sendValueChangedSignal()
                        }
                    }
                }
            }
        }
    }

    ColumnLayout{
        visible: unitComponent.currentIndex == 1
        LibConfig.SliderComponent{
            enabled: !fillComponent.checked || (fillComponent.checked && plasmoidVertical)
            label: i18n("Height")
            suffix: i18n("%")
            id: heightPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['heightPercent']['top'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            enabled: !fillComponent.checked || (fillComponent.checked && !plasmoidVertical)
            label: i18n("Width")
            suffix: i18n("%")
            id: widthPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['widthPercent']['top'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            enabled: !fillComponent.checked || (fillComponent.checked && !plasmoidVertical)
            label: i18n("Corner Radius")
            suffix: i18n("%")
            id: radiusPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['radiusPercent']['top'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Top")
            suffix: i18n("%")
            id: marginTopPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['marginsPercent']['top'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Left")
            suffix: i18n("%")
            id: marginLeftPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['marginsPercent']['left'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Right")
            suffix: i18n("%")
            id: marginRightPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['marginsPercent']['right'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
        LibConfig.SliderComponent{
            label: i18n("Margin Bottom")
            suffix: i18n("%")
            id: marginBottomPercentComponent
            from: 0
            to: 100
            stepSize: 1
            decimals: 0
            onValueChanged: {
                valueArr['marginsPercent']['bottom'] = value
                indicatorOptions.sendValueChangedSignal()
            }
        }
    }
    function getKeys(){
        return {
            baseKey: 'indicator',
            unitKeys: [
                'height',
                'width',
                'radius',
            ],
            optionKeys: [
                'aniduration',
                'location',
                'align',
                'fill',
                'unit'
            ],
            optionValueVar: {
                aniduration: 'value',
                location: 'currentIndex',
                align: 'currentIndex',
                fill: 'checked',
                unit: 'currentIndex'
            },
            marginKeys: [
                'Top',
                'Left',
                'Right',
                'Bottom'
            ],
            percent: 'Percent',
            component: 'Component',
            margins: 'margins'
        }
    }

    Component.onCompleted: {
        indicatorOptions.ready = true
    }

    function insertValues(obj) {
    
        indicatorOptions.inserting = true
        console.log(indicatorOptions.inserting)
        valueArr = obj
        let keys = getKeys()
        for(let key in keys.unitKeys){
            console.log(keys.unitKeys[key])
            indicatorOptions[keys.unitKeys[key] + keys['component']] = obj[keys.unitKeys[key]]
            indicatorOptions[keys.unitKeys[key] + keys['percent'] + keys['component']] = obj[(keys.unitKeys[key] + keys['percent'])]
        }
        for(let key in keys.marginKeys){
            console.log(keys.marginKeys[key])
            indicatorOptions[keys['margins'] + keys.marginKeys[key] + keys['component']] = obj[keys['margins'][keys.marginKeys[key]]]
            indicatorOptions[keys['margins'] + keys.marginKeys[key] + keys['percent'] + keys['component']] = obj[(keys['margins'] + keys['percent'])[keys.marginKeys[key]]]
        }
        for(let key in keys.optionKeys){
            console.log(keys.optionKeys[key])
            indicatorOptions[keys.optionKeys[key] + keys['component']][keys[optionValueVar][key]] = obj['key']
        }
        indicatorOptions.inserting = false
        console.log(indicatorOptions.inserting)
    }   
    function sendValueChangedSignal(){
        console.log(indicatorOptions.ready)
        console.log(indicatorOptions.inserting)
        if(indicatorOptions.inserting) return;
        if(indicatorOptions.ready) indicatorOptions.valueChanged()  
    }
}