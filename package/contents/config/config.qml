/*
    SPDX-FileCopyrightText: 2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "../configcomponents/ConfigAppearance.qml"
    }
    ConfigCategory {
        name: i18n("Colors")
        icon: "preferences-desktop-theme-global"
        source: "../configcomponents/ConfigColors.qml"
    }
    ConfigCategory {
        name: i18n("Indicators")
        icon: "preferences-desktop-navigation"
        source: "../configcomponents/ConfigIndicators.qml"
    }
    ConfigCategory {
         name: i18n("Behavior")
         icon: "preferences-desktop"
         source: "../configcomponents/ConfigBehavior.qml"
    }
    ConfigCategory {
        name: i18n("Advanced")
        icon: "configure"
        source: "../lib/ConfigAdvanced.qml"
    }
    ConfigCategory {
        name: i18n("Donate")
        icon: "view-financial-account-cash"
        source: "../configcomponents/ConfigDonate.qml"
    }
}
