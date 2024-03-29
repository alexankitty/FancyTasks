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

Kirigami.FormLayout {
    anchors.left: parent.left
    anchors.right: parent.right
    wideMode: false

    property bool plasmoidVertical: TaskTools.isVertical(indicatorLocation.currentIndex)
    property alias cfg_indicatorsEnabled: indicatorsEnabled.currentIndex //type: Int; label: Enable taskbar indicator effect. 0 = Off, 1 = On; default: 0
    property alias cfg_indicatorProgress: indicatorProgress.currentIndex //type: Bool; label: Display progress on indicator instead of button; default: false
    property alias cfg_indicatorLocation: indicatorLocation.currentIndex //type: Int; label: Sets where the indicator should be. 0 = Top, 1 = Bottom, 2 = Left, 3 = Right; default: 0
    property var cfg_buttonProperties

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
        ColumnLayout {
            enabled: indicatorsEnabled.currentIndex
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
                        id: indicatorHeight
                        from: 1
                        to: 999
                    }
                }
                
                RowLayout{
                    Label {
                        text: i18n("Width (px):")
                    }
                    SpinBox {
                        enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && plasmoidVertical)
                        id: indicatorWidth
                        from: 1
                        to: 999
                    }
                }

                RowLayout {
                    Label {
                        text: i18n("Corner Radius (px):")
                    }
                    SpinBox {
                        id: indicatorRadius
                        from: 0
                        to: 100
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
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: i18n("Bottom")
                            }
                            SpinBox {
                                id: indicatorMarginRight
                                from: 0
                                to: 999
                            }
                        }
                        ColumnLayout{
                            Label{
                                text: i18n("Right")
                            }
                            SpinBox {
                                id: indicatorMarginBottom
                                from: 0
                                to: 999
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
                    id: indicatorHeightPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
                }
                LibConfig.SliderComponent{
                    enabled: !indicatorFillAvailable.checked || (indicatorFillAvailable.checked && !plasmoidVertical)
                    label: i18n("Width")
                    suffix: i18n("%")
                    id: indicatorWidthPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
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
                }
                LibConfig.SliderComponent{
                    label: i18n("Margin Top")
                    suffix: i18n("%")
                    id: indicatorMarginTopPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
                }
                LibConfig.SliderComponent{
                    label: i18n("Margin Left")
                    suffix: i18n("%")
                    id: indicatorMarginLeftPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
                }
                LibConfig.SliderComponent{
                    label: i18n("Margin Right")
                    suffix: i18n("%")
                    id: indicatorMarginRightPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
                }
                LibConfig.SliderComponent{
                    label: i18n("Margin Bottom")
                    suffix: i18n("%")
                    id: indicatorMarginBottomPercent
                    from: 0
                    to: 100
                    stepSize: 1
                    decimals: 0
                }
            }

            Item {
                Kirigami.FormData.isSection: true
            }
        }
    }
}