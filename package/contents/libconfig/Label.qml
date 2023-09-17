// Version 3

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.2 as Kirigami

QQC2.Label {
	Layout.fillWidth: true
	wrapMode: Text.Wrap
	linkColor: Kirigami.Theme.highlightColor
	onLinkActivated: Qt.openUrlExternally(link)
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
		cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
	}
}
