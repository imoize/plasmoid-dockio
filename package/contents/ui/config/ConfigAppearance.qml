import QtQuick
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

KCM.SimpleKCM {
    id: appearanceConfigPage

    property alias cfg_showProgressBar : showProgressBar.checked
    property alias cfg_showStatusBar : showStatusBar.checked
    property alias cfg_moveDeleteButton : moveDeleteButton.checked
    
    ColumnLayout {
        id: infoAppearanceMessage
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: ""
            type: Kirigami.MessageType.Warning
            visible: false
        }
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "This feature is still experimental. Enabling the refresh bar indicator may or may not impact resource usage."
            type: Kirigami.MessageType.Warning
            visible: true
        }
    }
    
    Kirigami.FormLayout {
        anchors.top: infoAppearanceMessage.bottom

        Item {
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: showProgressBar

            Kirigami.FormData.label: i18n("Enable refresh bar indicator:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: moveDeleteButton

            Kirigami.FormData.label: i18n("Move delete button to context menu:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        PlasmaComponents.CheckBox {
            id: showStatusBar

            Kirigami.FormData.label: i18n("Enable status bar:")
        }

    }
}