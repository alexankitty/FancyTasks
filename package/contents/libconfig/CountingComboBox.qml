import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../libconfig" as LibConfig

RowLayout {
    height: childrenRect.height
    width: childrenRect.width
    property alias currentIndex: countedBox.currentIndex
    property int entryCount
    objectName: "CountingComboBox"
    id: countingComboBox
    ComboBox {
        id: countedBox
        model: {
            let tailArr = []
            for(let x = 1; x <= entryCount; x++ ){
                tailArr.push(x)
            }
            return tailArr
        }
    }
}