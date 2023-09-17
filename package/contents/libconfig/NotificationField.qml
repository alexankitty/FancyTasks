// Version 5

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.3 as Kirigami

import "." as LibConfig

ColumnLayout {
	id: notificationField

	property alias notificationEnabledKey: enabledCheckBox.configKey
	property alias sfxEnabledKey: soundField.sfxEnabledKey
	property alias sfxPathKey: soundField.sfxPathKey

	property alias enabledLabel: enabledCheckBox.text
	property alias sfxLabel: soundField.label

	property alias notificationEnabled: enabledCheckBox.checked
	property alias sfxEnabled: soundField.sfxEnabled
	property alias sfxPath: soundField.sfxPath
	property alias sfxDefaultPath: soundField.sfxDefaultPath

	property int indentWidth: 6 * Kirigami.Units.devicePixelRatio

	// Assign buddyFor so the Kirigami label aligns with it.
	Kirigami.FormData.buddyFor: enabledCheckBox

	spacing: 0

	LibConfig.CheckBox {
		id: enabledCheckBox
		text: i18n("Notification")
	}
	RowLayout {
		spacing: 0
		Item { implicitWidth: indentWidth } // indent
		QQC2.Label {
			text: '└─ '
		}
		LibConfig.SoundField {
			id: soundField
			label: i18n("SFX:")
			enabled: notificationEnabled
		}
	}
}
