import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Menu {
    id: contextMenu
    modal: true
    y: contextMenuButton.height
    width: Kirigami.Units.gridUnit * 8
    rightMargin: Kirigami.Units.smallSpacing * 3
    closePolicy: QQC2.Popup.CloseOnPressOutside

    property string containerId: ""
    property string containerName: ""

    signal closeContextMenu

    PlasmaComponents.Menu {
        id: execMenu
        width: Kirigami.Units.gridUnit * 7
        title: i18n("Exec")
        icon.name: Qt.resolvedUrl("../icons/dockio-term.svg")
        closePolicy: QQC2.Popup.CloseOnPressOutside

        PlasmaComponents.MenuItem {
            text: i18n("/bin/ash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} ash"`);
            }
            onHoveredChanged: {
                if (!hovered) {
                    highlighted = false;
                }
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/bash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} bash"`);
            }
            onHoveredChanged: {
                if (!hovered) {
                    highlighted = false;
                }
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/dash")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} dash"`);
            }
            onHoveredChanged: {
                if (!hovered) {
                    highlighted = false;
                }
            }
        }

        PlasmaComponents.MenuItem {
            text: i18n("/bin/sh")
            onTriggered: {
                dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker exec -it ${containerId} sh"`);
            }
            onHoveredChanged: {
                if (!hovered) {
                    highlighted = false;
                }
            }
        }
    }

    PlasmaComponents.MenuSeparator {}

    PlasmaComponents.MenuItem {
        text: i18n("Logs")
        icon.name: Qt.resolvedUrl("../icons/dockio-logs.svg")
        onTriggered: {
            dockerCommand.executable.exec(cfg.terminalCommand + ` $SHELL -c "docker logs -f ${containerId}"`);
        }
        onHoveredChanged: {
            if (!hovered) {
                highlighted = false;
            }
        }
    }

    PlasmaComponents.MenuSeparator {
        visible: cfg.moveDeleteButton
        height: visible ? undefined : 0
    }

    PlasmaComponents.MenuItem {
        visible: cfg.moveDeleteButton
        height: visible ? undefined : 0
        text: i18n("Delete")
        icon.name: Qt.resolvedUrl("../icons/dockio-trash.svg")
        onTriggered: {
            containerListPage.createActionsDialog(containerId, containerName, "delete");
        }
        onHoveredChanged: {
            if (!hovered) {
                highlighted = false;
            }
        }
    }

    onClosed: {
        contextMenuButton.checked = false;
        closeContextMenu();
    }
}
