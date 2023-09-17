// Version 3

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0

QQC2.Slider {
	id: slider

	property string configKey: ''
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""

	value: configValue
	onValueChanged: serializeTimer.start()

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				plasmoid.configuration[configKey] = slider.value
			}
		}
	}
}
