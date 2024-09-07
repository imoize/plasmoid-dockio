import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

ColumnLayout{
    id: containerListPage
    spacing: 0

    property alias view: containerListView
    property alias model: containerListView.model

    Kirigami.InlineMessage {
        id: errorMessage
        width: parent.width
        type: Kirigami.MessageType.Error
        icon.name: Qt.resolvedUrl("icons/dockio-error.svg")
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
    PlasmaComponents.ProgressBar {
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
                        if (filter.text !== "") return Qt.resolvedUrl("icons/dockio-cube.svg");
                        else if (error !== "") return Qt.resolvedUrl("icons/dockio-error.svg");
                        else return Qt.resolvedUrl("icons/dockio-icon.svg");
                    }
                }
            }
        }
    }

    KSvg.SvgItem {
        Layout.fillWidth: true
        Layout.topMargin: 0
        Layout.bottomMargin: 0
        visible: cfg.showStatusBar && dockerEnable
        imagePath: "widgets/line"
        elementId: "horizontal-line"
    }

    Rectangle {
        id: mainStatusBar
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Kirigami.Units.smallSpacing
        visible: cfg.showStatusBar && dockerEnable
        height: mainStatusBarContent.height
        color: "transparent"
        bottomLeftRadius: 5
        bottomRightRadius: 5

        RowLayout {
            id: mainStatusBarContent
            anchors.verticalCenter: parent.verticalCenter
            ColumnLayout {
            spacing: 1

                PlasmaComponents.Label {
                    text: i18n("Images: ") + dockerCommand.infoArray.Images
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }

                PlasmaComponents.Label {
                    text: i18n("Containers: ") + dockerCommand.infoArray.Containers
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }

            ColumnLayout {
                spacing: 1

                Item { 
                    Layout.fillHeight: true
                }

                PlasmaComponents.Label {
                    text: i18n("Running: ") + dockerCommand.infoArray.ContainersRunning
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }

            ColumnLayout {
                spacing: 1

                Item { 
                    Layout.fillHeight: true
                }

                PlasmaComponents.Label {
                    text: i18n("Stopped: ") + dockerCommand.infoArray.ContainersStopped
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
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