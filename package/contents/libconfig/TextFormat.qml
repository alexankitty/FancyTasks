// Version 3

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.0 as Kirigami

import "." as LibConfig

RowLayout {
	id: configTextFormat

	property alias boldConfigKey: configBold.configKey
	property alias italicConfigKey: configItalic.configKey
	property alias underlineConfigKey: configUnderline.configKey
	property alias alignConfigKey: configTextAlign.configKey
	property alias vertAlignConfigKey: configVertAlign.configKey

	QQC2.Button {
		id: configBold
		property string configKey: ''
		visible: configKey
		icon.name: 'format-text-bold-symbolic'
		checkable: true
		checked: configKey ? plasmoid.configuration[configKey] : false
		onClicked: plasmoid.configuration[configKey] = checked
	}

	QQC2.Button {
		id: configItalic
		property string configKey: ''
		visible: configKey
		icon.name: 'format-text-italic-symbolic'
		checkable: true
		checked: configKey ? plasmoid.configuration[configKey] : false
		onClicked: plasmoid.configuration[configKey] = checked
	}

	QQC2.Button {
		id: configUnderline
		property string configKey: ''
		visible: configKey
		icon.name: 'format-text-underline-symbolic'
		checkable: true
		checked: configKey ? plasmoid.configuration[configKey] : false
		onClicked: plasmoid.configuration[configKey] = checked
	}

	Item {
		implicitWidth: Kirigami.Units.smallSpacing
		readonly property bool groupBeforeVisible: configBold.visible || configItalic.visible || configUnderline.visible
		readonly property bool groupAfterVisible: configTextAlign.visible || configVertAlign.visible
		visible: groupBeforeVisible && groupAfterVisible
	}

	LibConfig.TextAlign {
		id: configTextAlign
		visible: configKey
	}

	Item {
		implicitWidth: Kirigami.Units.smallSpacing
		readonly property bool groupBeforeVisible: configBold.visible || configItalic.visible || configUnderline.visible || configTextAlign.visible
		readonly property bool groupAfterVisible: configTextAlign.visible
		visible: groupBeforeVisible && groupAfterVisible
	}

	LibConfig.VertAlign {
		id: configVertAlign
		visible: configKey
	}
}
