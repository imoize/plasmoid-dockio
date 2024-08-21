import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

ColumnLayout{
    id: containerListPage

    property alias view: containerListView
    property alias model: containerListView.model

    Kirigami.InlineMessage {
        id: errorMessage
        width: parent.width
        type: Kirigami.MessageType.Error
        icon.name: "dockio-error"
        text: main.error
        visible: main.error != ""
        actions: Kirigami.Action {
            text: i18nc("@action:button","Clear")
            onTriggered: {
                error = ""
                Utils.initState();
            }
        }
    }

    // Experimental: Progress Bar
    QQC2.ProgressBar {
        id: progressBar
        visible: cfg.showProgressBar && dockerEnable && containerListView.count !== 0
        topInset: 0
        topPadding: 0
        bottomInset: 0
        bottomPadding: 0
        spacing: Kirigami.Units.smallSpacing
        Layout.fillWidth: true
        from: 0
        to: 100
        value: 0
        indeterminate: false

        SequentialAnimation on value {
            id: progressBarAnimation
            running: cfg.showProgressBar && dockerEnable && main.expanded
            loops: Animation.Infinite

            NumberAnimation {
                from: 0
                to: 100
                duration: cfg.fetchContainerInterval * 1000
                easing.type: Easing.Linear
            }
            PauseAnimation {
                duration: 0
            }
        }
    }

    PlasmaComponents.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        background: null

        contentItem: ListView {
            id: containerListView

            model: containerModel
            highlight: PlasmaExtras.Highlight { }
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            currentIndex: -1
            reuseItems: true

            Connections {
                target: main
                function onExpandedChanged() {
                    if (main.expanded) {
                        containerListView.currentIndex = -1
                        containerListView.positionViewAtBeginning()
                    }
                }
            }

            delegate: ContainerItemDelegate {
                showSeparator: index !== 0
                width: containerListView.width

                Binding {
                    target: containerListView
                    when: hovered
                    property: "currentIndex"; value: index
                    restoreMode: Binding.RestoreBinding
                }
            }

            Loader {
                id: emptySearch

                anchors.centerIn: parent
                width: parent.width - (Kirigami.Units.gridUnit * 4)
                visible: containerListView.count === 0
                asynchronous: true

                sourceComponent: Kirigami.PlaceholderMessage {
                    width: parent.width
                    text: {
                        if (filter.text !== "") return "No results.";
                        else if (error !== "") return "Some error occurred.";
                        else return "Start your docker!";
                        }
                    icon.name: {
                        if (filter.text !== "") return "dockio-cube";
                        else if (error !== "") return "dockio-error";
                        else return "dockio-icon";
                    }
                }
            }
        }
    }

    Connections {
        target: main
        function onStartProgressBar() {
            progressBarAnimation.stop(); // Experimental: Stop progress bar animation
            progressBar.value = 0 // Experimental: Reset progress bar value to 0
            progressBarAnimation.start(); // Experimental: Start progress bar animation
            }
        function onStopProgressBar() {
            progressBarAnimation.stop();
            progressBar.value = 0 
        }
    }
}