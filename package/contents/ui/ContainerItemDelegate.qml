import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

PlasmaComponents.ItemDelegate {
    id: containerItem

    property bool showSeparator
    height: Math.max(label.height, Math.round(Kirigami.Units.gridUnit * 1.6)) + 2 * Kirigami.Units.smallSpacing
    enabled: true

    signal toOptPage(string ids, string name, string info)

    onToOptPage: (ids, name, info) => {
        stack.push(Qt.resolvedUrl("ContainerOptPage.qml"), {
            containerId: ids,
            containerName: name,
            containerInfo: info
        });
    }

    MouseArea {
        anchors.fill: parent
        // propagateComposedEvents: true
        hoverEnabled: true
        onEntered: {
            containerListView.currentIndex = index
        }
        onClicked: {
        containerItem.toOptPage(containerId, containerName, containerInfo)
        }
        onExited: {
            if (containerListView.currentIndex === index) {
                containerListView.currentIndex = -1
            }
        }

        Item {
            id: label
            height: childrenRect.height
            anchors {
                left: parent.left
                leftMargin: Kirigami.Units.gridUnit - 9
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    id: nameLabel
                    text: containerName
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.bold: true
                }

                RowLayout {
                    spacing: 0
                    PlasmaComponents.Label {
                        id: statusLabel
                        text: "Status: "
                        // Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }

                    PlasmaComponents.Label {
                        text: containerState + " - " + containerStatus
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.capitalization: Font.Capitalize
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        color: {
                            if ( containerState === "exited" ) {
                            Kirigami.Theme.negativeTextColor
                            } else if ( containerState === "running" ) {
                            Kirigami.Theme.positiveTextColor
                            }
                        }
                    }
                }
                
                PlasmaComponents.Label {
                    id: imageLabel
                    text: "Image: " + containerImage
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                }
            }
        }

        Loader {
            id: toolButtonsLoader
            anchors {
                right: label.right
                verticalCenter: parent.verticalCenter
                topMargin: parent.verticalCenter
            }
            active: true
            source: "ToolButtonsDelegate.qml"
        }
    }

    KSvg.SvgItem {
        id: separatorLine
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
        }
        imagePath: "widgets/line"
        elementId: "horizontal-line"
        width: parent.width - Kirigami.Units.gridUnit
        visible: showSeparator
    }
}