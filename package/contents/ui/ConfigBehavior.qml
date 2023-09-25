/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

Item {
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_groupingStrategy: groupingStrategy.currentIndex //type: Enum; label: How tasks are grouped: 0 = Do Not Group, 1 = By Program Name; default: 1
    property alias cfg_groupedTaskVisualization: groupedTaskVisualization.currentIndex //type: Enum; label: What happens when clicking on a grouped task: 0 = cycle through grouped tasks, 1 = try to show tooltips, 2 = try to show present Windows effect, 3 = show textual list (AKA group dialog); default: 0
    property alias cfg_groupPopups: groupPopups.checked //type: Bool; label: Whether groups are to be reduced to a single task button and expand into a popup or task buttons are grouped on the widget itself.; default: true
    property alias cfg_onlyGroupWhenFull: onlyGroupWhenFull.checked //type: Bool; label: Whether to group always or only when the widget runs out of space to show additional task buttons comfortably.; default: true
    property alias cfg_sortingStrategy: sortingStrategy.currentIndex //type: Int; label: How to sort tasks: 0 = Do Not Sort, 1 = Manually, 2 = Alphabetically, 3 = By Desktop, 4 = By Activity; default: 1
    property alias cfg_separateLaunchers: separateLaunchers.checked //type: Bool; label: Whether launcher tasks are sorted separately at the left side of the widget or can be mixed with other tasks.; default: true
    property alias cfg_middleClickAction: middleClickAction.currentIndex //type: Enum; label: What to do on middle-mouse click on a task button.; enum: None Close NewInstance ToggleMinimized ToggleGrouping BringToCurrentDesktop; default: 2
    property alias cfg_wheelEnabled: wheelEnabled.checked //type: Bool; label: Whether using the mouse wheel with the mouse pointer above the widget should switch between tasks.; default: true
    property alias cfg_wheelSkipMinimized: wheelSkipMinimized.checked //type: Bool; label: Whether to skip minimized tasks when switching between them using the mouse wheel.; default: true
    property alias cfg_showOnlyCurrentScreen: showOnlyCurrentScreen.checked //type: Bool; label: Whether to show only window tasks that are on the same screen as the widget.; default: false
    property alias cfg_showOnlyCurrentDesktop: showOnlyCurrentDesktop.checked //type: Bool; label: Whether to only show tasks that are on the current virtual desktop.; default: true
    property alias cfg_showOnlyCurrentActivity: showOnlyCurrentActivity.checked //type: Bool; label: Whether to show only tasks that are on the current activity.; default: true
    property alias cfg_showOnlyMinimized: showOnlyMinimized.checked //type: Int; label: Whether to show only window tasks that are minmized.; default: false
    property alias cfg_minimizeActiveTaskOnClick: minimizeActive.checked //type: Bool; label: Whether to minimize the currently-active task when clicked. If false, clicking on the currently-active task will do nothing.; default: true
    property alias cfg_unhideOnAttention: unhideOnAttention.checked //type: Bool; label: Whether to unhide if a window wants attention.; default: true
    property alias cfg_reverseMode: reverseMode.checked //type: Bool; label: Whether to grow the tasks in according to system configuration or opposite to system configuration.; default: false
    property alias cfg_iconOnly: iconOnly.currentIndex //type: Enum; label: How tasks are display: 0 = Show Task Names, 1 = Show Icons Only; default: 1

    TaskManagerApplet.Backend {
        id: backend
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        ComboBox {
            id: iconOnly
            Kirigami.FormData.label: i18n("Display:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
            model: [i18n("Show task names"), i18n("Show icons only")]
        }

        ComboBox {
            id: groupingStrategy
            Kirigami.FormData.label: i18n("Group:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
            model: [i18n("Do not group"), i18n("By program name")]
        }

        ComboBox {
            id: groupedTaskVisualization
            Kirigami.FormData.label: i18n("Clicking grouped task:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14

            enabled: groupingStrategy.currentIndex !== 0

            model: [
                i18nc("Completes the sentence 'Clicking grouped task cycles through tasks' ", "Cycles through tasks"),
                i18nc("Completes the sentence 'Clicking grouped task shows tooltip window thumbnails' ", "Shows tooltip window thumbnails"),
                i18nc("Completes the sentence 'Clicking grouped task shows windows side by side' ", "Shows windows side by side"),
                i18nc("Completes the sentence 'Clicking grouped task shows textual list' ", "Shows textual list"),
            ]
        }
        // "You asked for Tooltips but Tooltips are disabled" message
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: groupedTaskVisualization.currentIndex === 1 && !plasmoid.configuration.showToolTips && backend.windowViewAvailable
            type: Kirigami.MessageType.Warning
            text: i18n("Tooltips are disabled, so the windows will be displayed side by side instead.")
        }
        // "You asked for Tooltips but Tooltips are disabled and Window View is not available" message
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: groupedTaskVisualization.currentIndex === 1 && !plasmoid.configuration.showToolTips && !backend.windowViewAvailable
            type: Kirigami.MessageType.Warning
            text: i18n("Tooltips are disabled, and the compositor does not support displaying windows side by side, so a textual list will be displayed instead")
        }
        // "You asked for Window View but Window View is not available" message
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: groupedTaskVisualization.currentIndex === 2 && !backend.windowViewAvailable
            type: Kirigami.MessageType.Warning
            text: i18n("The compositor does not support displaying windows side by side, so a textual list will be displayed instead.")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: groupPopups
            visible: (!plasmoid.configuration.iconOnly)
            text: i18n("Combine into single button")
            enabled: groupingStrategy.currentIndex > 0
        }

        CheckBox {
            id: onlyGroupWhenFull
            visible: (!plasmoid.configuration.iconOnly)
            text: i18n("Group only when the Task Manager is full")
            enabled: groupingStrategy.currentIndex > 0 && groupPopups.checked
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: (!plasmoid.configuration.iconOnly)
        }

        ComboBox {
            id: sortingStrategy
            Kirigami.FormData.label: i18n("Sort:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
            model: [i18n("Do not sort"), i18n("Manually"), i18n("Alphabetically"), i18n("By desktop"), i18n("By activity")]
        }

        CheckBox {
            id: separateLaunchers
            visible: (!plasmoid.configuration.iconOnly)
            text: i18n("Keep launchers separate")
            enabled: sortingStrategy.currentIndex == 1
        }

        Item {
            Kirigami.FormData.isSection: true
            visible: (!plasmoid.configuration.iconOnly)
        }

        CheckBox {
            id: minimizeActive
            Kirigami.FormData.label: i18nc("Part of a sentence: 'Clicking active task minimizes the task'", "Clicking active task:")
            text: i18nc("Part of a sentence: 'Clicking active task minimizes the task'", "Minimizes the task")
        }

        ComboBox {
            id: middleClickAction
            Kirigami.FormData.label: i18n("Middle-clicking any task:")
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 14
            model: [
                i18nc("Part of a sentence: 'Middle-clicking any task does nothing'", "Does nothing"),
                i18nc("Part of a sentence: 'Middle-clicking any task closes window or group'", "Closes window or group"),
                i18nc("Part of a sentence: 'Middle-clicking any task opens a new window'", "Opens a new window"),
                i18nc("Part of a sentence: 'Middle-clicking any task minimizes/restores window or group'", "Minimizes/Restores window or group"),
                i18nc("Part of a sentence: 'Middle-clicking any task toggles grouping'", "Toggles grouping"),
                i18nc("Part of a sentence: 'Middle-clicking any task brings it to the current virtual desktop'", "Brings it to the current virtual desktop")
            ]
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: wheelEnabled
            Kirigami.FormData.label: i18nc("Part of a sentence: 'Mouse wheel cycles through tasks'", "Mouse wheel:")
            text: i18nc("Part of a sentence: 'Mouse wheel cycles through tasks'", "Cycles through tasks")
        }

        RowLayout {
            // HACK: Workaround for Kirigami bug 434625
            // due to which a simple Layout.leftMargin on CheckBox doesn't work
            Item { implicitWidth: Kirigami.Units.gridUnit }
            CheckBox {
                id: wheelSkipMinimized
                text: i18n("Skip minimized tasks")
                enabled: wheelEnabled.checked
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: showOnlyCurrentScreen
            Kirigami.FormData.label: i18n("Show only tasks:")
            text: i18n("From current screen")
        }

        CheckBox {
            id: showOnlyCurrentDesktop
            text: i18n("From current desktop")
        }

        CheckBox {
            id: showOnlyCurrentActivity
            text: i18n("From current activity")
        }

        CheckBox {
            id: showOnlyMinimized
            text: i18n("That are minimized")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: unhideOnAttention
            Kirigami.FormData.label: i18n("When panel is hidden:")
            text: i18n("Unhide when a window wants attention")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        ButtonGroup {
            id: reverseModeRadioButtonGroup
        }

        RadioButton {
            Kirigami.FormData.label: i18n("New tasks appear:")
            checked: !reverseMode.checked
            text: Qt.application.layoutDirection === Qt.LeftToRight ? i18n("To the right") : i18n("To the left")
            ButtonGroup.group: reverseModeRadioButtonGroup
            visible: reverseMode.visible
        }

        RadioButton {
            id: reverseMode
            checked: plasmoid.configuration.reverseMode === true
            text: Qt.application.layoutDirection === Qt.RightToLeft ? i18n("To the right") : i18n("To the left")
            ButtonGroup.group: reverseModeRadioButtonGroup
            visible: plasmoid.formFactor === PlasmaCore.Types.Horizontal
        }

    }
}
