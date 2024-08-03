import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: generalConfigPage

    property alias cfg_pollApiInterval: pollApiInterval.value
    property alias cfg_fetchContainerInterval: fetchContainerInterval.value
    property alias cfg_useNotif: useNotif.checked
    property alias cfg_fetchOnExpand: fetchOnExpand.checked
    property alias cfg_fetchOnStart: fetchOnStartup.checked
    property alias cfg_debug: debug.checked

    ColumnLayout {
        id: infoGeneralMessage
        Kirigami.InlineMessage {
            id: infoPollInterval
            Layout.fillWidth: true
            text: "Poll API interval will run every 30 seconds, which may consume excessive resources and impact battery life. Consider increasing the value."
            type: (pollApiInterval.value < 10) ? Kirigami.MessageType.Error : Kirigami.MessageType.Warning
            visible: pollApiInterval.value < 15
        }
        Kirigami.InlineMessage {
            id: infoFetchContainer
            Layout.fillWidth: true
            text: "Fetch containers interval will run every 30 seconds, which may consume excessive resources and impact battery life. Consider increasing the value."
            type: (fetchContainerInterval.value < 10) ? Kirigami.MessageType.Error : Kirigami.MessageType.Warning
            visible: fetchContainerInterval.value < 15
        }
    }
    
    Kirigami.FormLayout {
        anchors.top: infoGeneralMessage.bottom

        QQC2.SpinBox {
            id: pollApiInterval

            from: 1
            to: 3600 // maximum of 1 hours
            stepSize: 1
            onValueChanged: {
                infoPollInterval.text = "Poll API interval will run every " + pollApiInterval.value + " seconds, which may consume excessive resources and impact battery life. Consider increasing the value."
            }
            Kirigami.FormData.label: i18n("Poll API Interval (s):")
        }

        QQC2.SpinBox {
            id: fetchContainerInterval

            from: 1
            to: 3600 // maximum of 1 hours
            stepSize: 1
            onValueChanged: {
                infoFetchContainer.text = "Fetch containers interval will run every " + fetchContainerInterval.value + " seconds, which may consume excessive resources and impact battery life. Consider increasing the value."
            }
            Kirigami.FormData.label: i18n("Fetch Containers Interval (s):")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: useNotif

            Kirigami.FormData.label: i18n("Enable Notifications:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: fetchOnExpand

            Kirigami.FormData.label: i18n("Fetch on expand:")
        }

        QQC2.CheckBox {
            id: fetchOnStartup

            Kirigami.FormData.label: i18n("Fetch on startup:")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: debug

            Kirigami.FormData.label: i18n("Debug:")
        }

    }
}
