// Version 3

import QtQuick 2.0
import QtQuick.Controls 1.0

CheckBox {
	id: configCheckBox

	property string configKey: ''
	checked: plasmoid.configuration[configKey]
	onClicked: plasmoid.configuration[configKey] = !plasmoid.configuration[configKey]
}
