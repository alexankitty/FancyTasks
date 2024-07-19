import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrols 2.0 as KQControls

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import "../libconfig" as LibConfig

import "../ui/code/tools.js" as TaskTools
import "../ui/code/colortools.js" as ColorTools

Kirigami.FormLayout {
    id: indicatorForm
    anchors.left: parent.left
    anchors.right: parent.right
    wideMode: false

    property bool plasmoidVertical: TaskTools.isVertical(indicatorLocation)
    property alias cfg_indicatorsEnabled: indicatorsEnabled.currentIndex //type: Int; label: Enable taskbar indicator effect. 0 = Off, 1 = On; default: 0
    property alias cfg_indicatorProgress: indicatorProgress.currentIndex //type: Bool; label: Display progress on indicator instead of button; default: false
    property alias indicatorLocation: options.location
    //property alias cfg_indicatorLocation: options.location //type: Int; label: Sets where the indicator should be. 0 = Top, 1 = Bottom, 2 = Left, 3 = Right; default: 0
    property var buttonProperties
    property var cfg_buttonProperties
    property bool building: false


    RowLayout {
        Label {
            text: i18n("Indicators:")
        }
        
        ComboBox {
            id: indicatorsEnabled
            model: [i18n("Disabled"), i18n("Enabled")]
        }
        Label {
            text: i18n("Progress on:")
        }
        ComboBox {
            id: indicatorProgress
            model: [i18n("Frame"), i18n("Indicator"), i18n("Both")]
        }
    }   
    
    Item{
        implicitHeight: childrenRect.height
        implicitWidth: childrenRect.width
        enabled: indicatorsEnabled.currentIndex

        ColumnLayout{
            RowLayout{
                Label {
                    text: i18n("Minimum:")
                }
                SpinBox {
                    enabled: indicatorsEnabled.currentIndex
                    id: indicatorMinLimit
                    from: 1
                    to: 10
                }
                Label {
                    text: i18n("Maximum:")
                }
                SpinBox {
                    enabled: indicatorsEnabled.currentIndex
                    id: indicatorMaxLimit
                    from: 1
                    to: 10
                }
            }

            Item {
                Kirigami.FormData.isSection: true
            }
            LibConfig.StateComboBox {
                id: state
                showProgress: buttonTab.selectedIndex !== 2 && indicatorProgress.currentIndex
            }
            LibConfig.ButtonTabComponent{
                id: buttonTab
                showButtonColors: false
                indicatorCount: indicatorMaxLimit.value
            }

            Frame {
                LibConfig.IndicatorOptions{
                    id: options
                    plasmoidVertical: indicatorForm.plasmoidVertical
                }
            }
            Connections {
                target: options
                function onValueChanged(){
                    
                }
            }
        }
    }
    Component.onCompleted: {
        indicatorForm.building = true
        getProperties();
        buildForm();
        /* colorSelectorConnector.enabled = true
        colorEnabledConnector.enabled = true */
        indicatorForm.building = false
    }

    function getType(){
        switch(buttonTab.selectedIndex){
            case 1: return 'indicator'
            case 2: return 'indicatorTail'
        }
    }

    function getProperties(){
        let propKey = buttonTab.indexEnum[buttonTab.selectedIndex] + ColorTools.capitalizeFirstLetter(state.indexEnum[state.currentIndex])
        buttonProperties = new ColorTools.buttonProperties(cfg_buttonProperties, propKey, 'indicatorProps');
    }

    function buildForm(){

    }

    function setProperties(){
        //do the things?
    }

}