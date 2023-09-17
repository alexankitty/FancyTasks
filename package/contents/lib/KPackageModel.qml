// Version 1

import QtQuick 2.0

ListModel {
	property string packageType
	property bool loaded: false

	readonly property var executable: ExecUtil {
		id: executable
		property string readStateCommand: '( kpackagetool5 --type="' + packageType + '" --list ; kpackagetool5 --g --type="' + packageType + '" --list ) | cat'

		function readState() {
			executable.exec(readStateCommand)
		}
		Component.onCompleted: {
			readState()
		}

		function parsePackageList(stdout) {
			clear()
			var lines = stdout.split('\n')
			for (var i = 0; i < lines.length; i++) {
				var line = lines[i]
				if (line.indexOf(packageType) >= 0) {
					// Treat line as:
					// Listing service types: KWin/Script in /usr/share/kwin/scripts/
					continue
				}
				var pluginId = line.trim()
				if (pluginId) {
					append({
						pluginId: pluginId,
					})
				}
			}
		}

		onExited: {
			if (command == readStateCommand) {
				parsePackageList(stdout)
				loaded = true
			}
		}

		function startsWith(a, b) {
			if (b.length <= a.length) {
				return a.substr(0, b.length) == b
			} else {
				return false
			}
		}
	}

	function contains(pluginId) {
		for (var i = 0; i < count; i++) {
			var item = get(i)
			if (item.id == pluginId) {
				return true
			}
		}
		return false
	}
}
