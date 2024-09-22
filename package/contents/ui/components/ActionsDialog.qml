import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Dialog {
    id: actionsDialog

    anchors.centerIn: parent
    contentWidth: Kirigami.Units.gridUnit * 18
    height: actionsDialogItem.height + footer.height + Kirigami.Units.gridUnit
    bottomInset: -10

    dim: true
    modal: true
    visible: true
    closePolicy: QQC2.Popup.CloseOnPressOutside

    property string containerId: ""
    property string containerName: ""
    property string action: ""

    signal doActions(string containerId, string containerName, string action)
    signal closeActionsDialog

    ColumnLayout {
        id: actionsDialogItem
        anchors.centerIn: parent
        Layout.preferredWidth: actionsDialog.width
        Layout.fillWidth: true
        Layout.fillHeight: true

        PlasmaComponents.Label {
            id: modelDialogMessage
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
            Layout.preferredWidth: actionsDialog.contentWidth
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            wrapMode: Text.WordWrap
            text: {
                if (actionsDialog.action === "delete") {
                    return i18n("Delete \"%1\" container ?", actionsDialog.containerName);
                } else {
                    return "";
                }
            }
        }
    }

    footer: QQC2.DialogButtonBox {
        id: dialogButtonBox
        alignment: Qt.AlignHCenter
    }

    QQC2.Overlay.modal: Rectangle {
        color: "#50000000"
        bottomLeftRadius: 5
        bottomRightRadius: 5
    }

    onAccepted: {
        if (actionsDialog.action === "delete") {
            actionsDialog.doActions(containerId, containerName, "delete");
        }
        actionsDialog.closeActionsDialog();
    }
    
    onRejected: {
        actionsDialog.closeActionsDialog();
    }
}
