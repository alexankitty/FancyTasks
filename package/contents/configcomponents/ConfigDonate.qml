import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kquickcontrols 2.0 as KQControls

Kirigami.FormLayout{
    Label{
        text: "If you like what I'm doing, consider donating on Ko-fi."
    }
    
    Image {
        source: "kofi_button_red.png"
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("https://ko-fi.com/alexankitty")
        }
    }
}