import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../libconfig" as LibConfig

RowLayout {
    height: childrenRect.height
    width: childrenRect.width
    property string labelText
    property alias currentIndex: comboBox.currentIndex
    property alias displayText: comboBox.displayText
    property alias model: comboBox.model
    signal activated
    id: maskingComboBox
    objectName: "MaskingComboBox" 
    Label {
        id: comboBoxLabel
        text: labelText
    }
    ComboBox {
        property int prevIndex
        id: comboBox
        textRole: "text"
        delegate: ItemDelegate {
            width: modelData.visible ? parent.width : 0
            height: modelData.visible ? implicitHeight : 0
            text: modelData.visible ? modelData.text : ""
            font.weight: state.currentIndex === index ? Font.DemiBold : Font.Normal
            highlighted: ListView.isCurrentItem
            visible: modelData.visible
            enabled: modelData.enabled
        }
        onActivated: {
            if(!model[currentIndex].enabled){
                if(currentIndex < count - 1 && prevIndex < currentIndex) currentIndex += 1
                else currentIndex -= 1
            }
            prevIndex = currentIndex
        }
    }
    Connections{
        target: comboBox
        function onActivated(){
            maskingComboBox.activated()
        }
    }
}
