import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../libconfig" as LibConfig


RowLayout {
    property alias currentIndex: stateBox.currentIndex
    property alias displayText: stateBox.displayText
    property var indexEnum: ['active', 'inactive', 'minimized', 'attention', 'progress', 'hover']
    property bool showProgress
    id: state
    signal activated
    RowLayout{
        LibConfig.MaskingComboBox{
            labelText: "State: "
            id: stateBox
            model: [
                {text: i18n("Active"), visible: true, enabled: true},
                {text: i18n("Inactive"), visible: true, enabled: true},
                {text: i18n("Minimized"), visible: true, enabled: true},
                {text: i18n("Attention"), visible: true, enabled: true},
                {text: i18n("Progress"), visible: showProgress, enabled: showProgress},
                {text: i18n("Hover"), visible: true, enabled: true}
            ]
        }
    }
    Connections{
        target: stateBox
        function onActivated(){
            state.activated()
        }
    }
}