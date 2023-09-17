// Version 3

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configTextAlign

	property string configKey: ''
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	
	property alias before: labelBefore.text
	property alias after: labelAfter.text

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

	Label {
		id: labelBefore
		text: ""
		visible: text
	}
	
	Button {
		id: vertTopButton
		iconName: "align-vertical-top"
		checkable: true
		onClicked: setValue(Text.AlignTop)
	}

	Button {
		id: vertCenterButton
		iconName: "align-vertical-center"
		checkable: true
		onClicked: setValue(Text.AlignVCenter)
	}

	Button {
		id: vertBottomButton
		iconName: "align-vertical-bottom"
		checkable: true
		onClicked: setValue(Text.AlignBottom)
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}
}
