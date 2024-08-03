import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

RowLayout {
    id: toolButtonsLayout
    spacing: 0
    visible: true

    QQC2.ToolButton  {
        id: debugStartToolButton
        visible: cfg.debug
        text: i18n("Start")
        icon.name: "dockio-start"
        onClicked: Utils.commands["startContainer"].run(containerId, containerName);

        PlasmaComponents.ToolTip{ text: parent.text }
        display:QQC2.AbstractButton.IconOnly
    }
    QQC2.ToolButton  {
        id: debugStopToolButton
        visible: cfg.debug
        text: i18n("Stop")
        icon.name: "dockio-stop"
        onClicked: Utils.commands["stopContainer"].run(containerId, containerName);

        PlasmaComponents.ToolTip{ text: parent.text }
        display:QQC2.AbstractButton.IconOnly
    }
    QQC2.ToolButton {
        id: actionToolButton
        visible: !cfg.debug
        text: ["running", "removing", "restarting", "created"].includes(containerState) ? i18n("Stop") : i18n("Start")
        icon.name: ["running", "removing", "restarting", "created"].includes(containerState) ? "dockio-stop" : "dockio-start"
        onClicked: {
            if (["running", "removing", "restarting", "created"].includes(containerState)) {
                Utils.commands["stopContainer"].run(containerId, containerName);
            } else {
                Utils.commands["startContainer"].run(containerId, containerName);
            }
        }

        PlasmaComponents.ToolTip { text: parent.text }
        display: QQC2.AbstractButton.IconOnly
    }
    QQC2.ToolButton  {
        id: restartToolButton
        text: i18n("Restart")
        icon.name: "dockio-refresh"
        onClicked: Utils.commands["restartContainer"].run(containerId, containerName);

        PlasmaComponents.ToolTip{ text: parent.text }
        display:QQC2.AbstractButton.IconOnly
    }
    QQC2.ToolButton {
        id: deleteToolButton
        text: i18n("Delete")
        icon.name: "dockio-trash"
        onClicked: Utils.commands["deleteContainer"].run(containerId, containerName);

        PlasmaComponents.ToolTip{ text: parent.text }
        display:QQC2.AbstractButton.IconOnly
    }
}
