import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../libconfig" as LibConfig

ColumnLayout{
    property bool showButtonColors: false
    property int indicatorCount: 0
    property bool enableIndicators: true
    property int selectedIndex: 0
    property var indexEnum: ['button', 'indicator', 'indicatorTail']
    property alias tailIndex: tailSelect.currentIndex
    signal activated
    id: buttonTabComponent
    objectName: "ButtonTabComponent"
    CheckBox {
        id: customizeTails
        visible: {
            if(indicatorTailTab.checked && indicatorCount > 2) {
                return true
            }
            else{
                tailSelect.currentIndex = 0
                return false
            }
        }
        checked: {
            if(indicatorCount < 3) return false
            else return checked
        }
        text: i18n("Customize Individual Indicator Tails")
    }
    RowLayout{
        TabBar{
            id: bar
            TabButton { 
                id: buttonTab
                text: i18n("Button")
            }
            TabButton {
                enabled: enableIndicators
                checked: !showButtonColors
                id: indicatorTab
                text: i18n("Indicator")
            }
            TabButton {
                enabled: enableIndicators && indicatorCount >= 2
                id: indicatorTailTab
                text: i18n("Indicator Tail")
            }
        }
        LibConfig.CountingComboBox{
            id: tailSelect
            entryCount: indicatorCount - 1
            enabled: customizeTails.checked
            visible: indicatorTailTab.checked && customizeTails.checked
        }
    }
    Connections{
        target: buttonTab
        function onCheckedChanged(){
            selectedIndex = 0
            buttonTabComponent.activated()
        }
    }
        Connections{
        target: indicatorTab
        function onCheckedChanged(){
            selectedIndex = 1
            buttonTabComponent.activated()
        }
    }
        Connections{
        target: indicatorTailTab
        function onCheckedChanged(){
            selectedIndex = 2
            buttonTabComponent.activated()
        }
    }
    Component.onCompleted: {
        if(!showButtonColors) bar.removeItem(buttonTab)
    }
}