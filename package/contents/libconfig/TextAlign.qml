// Version 3

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0

RowLayout {
	id: configTextAlign

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
		justifyLeftButton.checked = Qt.binding(function(){ return configValue == Text.AlignLeft })
		justifyCenterButton.checked = Qt.binding(function(){ return configValue == Text.AlignHCenter })
		justifyRightButton.checked = Qt.binding(function(){ return configValue == Text.AlignRight })
		justifyFillButton.checked = Qt.binding(function(){ return configValue == Text.AlignJustify })
	}

	Component.onCompleted: updateChecked()

	QQC2.Button {
		id: justifyLeftButton
		icon.name: "format-justify-left-symbolic"
		checkable: true
		onClicked: setValue(Text.AlignLeft)
	}

	QQC2.Button {
		id: justifyCenterButton
		icon.name: "format-justify-center-symbolic"
		checkable: true
		onClicked: setValue(Text.AlignHCenter)
	}

	QQC2.Button {
		id: justifyRightButton
		icon.name: "format-justify-right-symbolic"
		checkable: true
		onClicked: setValue(Text.AlignRight)
	}

	QQC2.Button {
		id: justifyFillButton
		icon.name: "format-justify-fill-symbolic"
		checkable: true
		onClicked: setValue(Text.AlignJustify)
	}
}
