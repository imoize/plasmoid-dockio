import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

ColumnLayout {
    id: containerOptPage
    spacing: 0
    Layout.topMargin: 0
    Layout.bottomMargin: 0

    property string containerId: ""
    property string containerName: ""
    property string containerInfo: ""
    property alias containerInspectText: containerInspectText

    property PlasmaExtras.PlasmoidHeading header: PlasmaExtras.PlasmoidHeading {
        background.visible: false

        RowLayout {
            id: statsToolbar
            spacing: 0
            anchors.fill: parent

            QQC2.Label {
                id: containerNameLabel
                leftPadding: Kirigami.Units.smallSpacing
                text: "Container: " + containerName
                Layout.fillWidth: true
                // elide: Text.ElideRight
                font.bold: true
            }
            QQC2.ToolButton {
                id: inspectToolButton
                text: i18n("Inspect")
                icon.name: "dockio-inspect"
                onClicked: {
                    Utils.commands["inspectContainer"].run(containerId, containerName);
                    containerInfoText.text = "";
                    containerInfoText.visible = false;
                    containerInspectText.visible = true;
                }
                PlasmaComponents.ToolTip{ text: parent.text }
                display:QQC2.AbstractButton.IconOnly
            }
            PlasmaComponents.Button {
                id: backButton
                // Layout.minimumWidth: Kirigami.Units.gridUnit * 4
                icon.name: "go-previous-view"
                icon.width: 16
                icon.height: 16
                rightPadding: Kirigami.Units.smallSpacing * 3
                text: i18n("Back")
                onClicked: {
                    if (containerInspectText.visible) {
                        containerInspectText.visible = false;
                        containerInspectText.text = "";
                        containerInfoText.text = containerInfo;
                        containerInfoText.visible = true;
                    } else {
                        stack.pop();
                    }
                }
            }
        }
    }

    PlasmaComponents.ScrollView {
        id: statsScrollView

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: PlasmaComponents.ScrollBar.vertical.visible ? 0 : Kirigami.Units.smallSpacing
        contentWidth: PlasmaComponents.ScrollBar.vertical.visible ? statsScrollView.width - Kirigami.Units.smallSpacing * 6 : statsScrollView.width

        PlasmaComponents.TextArea {
            id: containerInfoText
            background: null
            width: statsScrollView.contentWidth
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            text: containerInfo
            visible: true
        }
        PlasmaComponents.TextArea {
            id: containerInspectText
            background: null
            width: statsScrollView.contentWidth
            readOnly: true
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            text: ""
            visible: false
        }
    }
}