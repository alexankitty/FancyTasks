// Version 4
// Forked ConfigIcon to use AppletIcon

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

RowLayout {
	id: configIcon
	
	default property alias _contentChildren: content.data

	property string configKey: ''
	property alias value: textField.text
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!textField.focus && value != configValue) {
			value = configValue
		}
	}
	property int previewIconSize: units.iconSizes.medium
	property string defaultValue: "start-here-kde"
	property var presetValues: []

	onPresetValuesChanged: iconMenu.refresh()

	// Used for binding in presetValue menu loop
	function setValue(val) {
		configIcon.value = val
	}

	// org.kde.plasma.kickoff
	Button {
		id: iconButton
		Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
		Layout.maximumWidth: Layout.minimumWidth
		Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
		Layout.maximumHeight: Layout.minimumWidth

		

		// just to provide some visual feedback, cannot have checked without checkable enabled
		checkable: true
		onClicked: {
			checked = Qt.binding(function() { // never actually allow it being checked
				return iconMenu.status === PlasmaComponents.DialogStatus.Open
			})

			iconMenu.open(0, height)
		}

		PlasmaCore.FrameSvgItem {
			id: previewFrame
			anchors.centerIn: parent
			imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
					 ? "widgets/panel-background" : "widgets/background"
			width: previewIconSize + fixedMargins.left + fixedMargins.right
			height: previewIconSize + fixedMargins.top + fixedMargins.bottom

			AppletIcon {
				anchors.centerIn: parent
				width: previewIconSize
				height: previewIconSize
				source: configIcon.value
			}
		}

		// QQC Menu can only be opened at cursor position, not a random one
		PlasmaComponents.ContextMenu {
			id: iconMenu
			visualParent: iconButton

			function newMenuItem(parent) {
				return Qt.createQmlObject(
					"import org.kde.plasma.components 2.0 as PlasmaComponents;" +
					"PlasmaComponents.MenuItem {}",
					parent);
			}

			function newSeparator(parent) {
				return Qt.createQmlObject(
					"import org.kde.plasma.components 2.0 as PlasmaComponents;" +
					"PlasmaComponents.MenuItem { separator: true }",
					parent);
			}

			function refresh() {
				clearMenuItems()

				// Choose...
				var menuItem = newMenuItem(iconMenu)
				menuItem.text = i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Open icon chooser dialog", "Choose...")
				menuItem.icon = "document-open"
				menuItem.clicked.connect(function(){
					iconDialog.open()
				})
				iconMenu.addMenuItem(menuItem)

				// Clear
				var menuItem = newMenuItem(iconMenu)
				menuItem.text = i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Reset icon to default", "Clear Icon")
				menuItem.icon = "edit-clear"
				menuItem.clicked.connect(function(){
					configIcon.value = defaultValue
				})
				iconMenu.addMenuItem(menuItem)

				// Preset Values
				if (configIcon.presetValues.length > 0) {
					menuItem = newSeparator(iconMenu)
					iconMenu.addMenuItem(menuItem)

					for (var i = 0; i < configIcon.presetValues.length; i++) {
						var presetValue = configIcon.presetValues[i]
						menuItem = newMenuItem(iconMenu)
						menuItem.text = presetValue
						menuItem.icon = presetValue
						menuItem.clicked.connect(configIcon.setValue.bind(this, presetValue))
						iconMenu.addMenuItem(menuItem)
					}
				}
			}

			Component.onCompleted: {
				refresh()
			}
		}
	}

	ColumnLayout {
		id: content
		Layout.fillWidth: true

		RowLayout {
			TextField {
				id: textField
				Layout.fillWidth: true

				text: configIcon.configValue
				onTextChanged: serializeTimer.restart()

				ToolButton {
					iconName: "edit-clear"
					onClicked: configIcon.value = defaultValue

					anchors.top: parent.top
					anchors.right: parent.right
					anchors.bottom: parent.bottom

					width: height
				}
			}

			Button {
				iconName: "document-open"
				onClicked: iconDialog.open()
			}
		}

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		Component.onDestruction: {
			while (children.length > 0) {
				children[children.length - 1].parent = configIcon;
			}
		}
	}

	KQuickAddons.IconDialog {
		id: iconDialog
		onIconNameChanged: configIcon.value = iconName
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				plasmoid.configuration[configKey] = configIcon.value
			}
		}
	}
}
