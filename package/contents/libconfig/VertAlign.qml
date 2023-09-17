// Version 4

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0

RowLayout {
	id: configVertAlign

	property string configKey: ''
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""

	function setValue(val) {
		if (configKey) {
			plasmoid.configuration[configKey] = val
		}
		updateChecked()
	}

	function updateChecked() {
		// button.checked bindings are unbound when clicked
		vertTopButton.checked = Qt.binding(function(){ return configValue == Text.AlignTop })
		vertCenterButton.checked = Qt.binding(function(){ return configValue == Text.AlignVCenter })
		vertBottomButton.checked = Qt.binding(function(){ return configValue == Text.AlignBottom })
	}

	Component.onCompleted: updateChecked()

	QQC2.Button {
		id: vertTopButton
		icon.name: "align-vertical-top"
		checkable: true
		onClicked: setValue(Text.AlignTop)
	}

	QQC2.Button {
		id: vertCenterButton
		icon.name: "align-vertical-center"
		checkable: true
		onClicked: setValue(Text.AlignVCenter)
	}

	QQC2.Button {
		id: vertBottomButton
		icon.name: "align-vertical-bottom"
		checkable: true
		onClicked: setValue(Text.AlignBottom)
	}
}
