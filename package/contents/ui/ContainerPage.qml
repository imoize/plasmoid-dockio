import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

ContainerListPage {
    id: containerPage

    property string sortBy: "ContainerName"
    property bool ascending: true

    property var header: PlasmaExtras.PlasmoidHeading {
        focus: main.expanded

        contentItem: RowLayout {
            spacing: 0
            
            enabled: containerModel.count > 0

            PlasmaComponents.ToolButton {
                id: sortButton
                property var sortable: [["containerName", "Container Name", "view-sort-ascending-name", "view-sort-descending-name"]]
                icon.name: sortButton.sortable[0][ascending ? 2 : 3]
                onClicked: {
                    ascending = !ascending
                    var sortBy = sortable[0][0]
                    if (filterModel) {
                        filterModel.sortRoleName = sortBy
                        filterModel.sortOrder = ascending ? Qt.AscendingOrder : Qt.DescendingOrder
                    }
                }

                display: QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip {
                    text: i18n(sortButton.sortable[0][1] + (ascending ? "" : "(Descending)"))
                }
            }

            PlasmaExtras.SearchField {
                id: filter
                Layout.fillWidth: true
                // focus: !Kirigami.InputMethod.willShowOnActive
            }
            
            PlasmaComponents.ToolButton {
                text: i18n("Refresh")
                icon.name: Qt.resolvedUrl("icons/dockio-refresh.svg")
                onClicked: {
                    dockerCommand.fetchContainers.get();
                    fetchTimer.restart();
                    startProgressBar();
                }
                display: QQC2.AbstractButton.IconOnly
                PlasmaComponents.ToolTip{ text: parent.text }
            }
        }
    }


    model: KItemModels.KSortFilterProxyModel {
        id: filterModel
        sourceModel: containerModel
        filterRoleName: "containerName"
        filterRegularExpression: RegExp(filter.text, "i")
        filterCaseSensitivity: Qt.CaseInsensitive
        sortCaseSensitivity: Qt.CaseInsensitive
        sortRoleName: sortBy
        recursiveFilteringEnabled: true
        sortOrder: ascending ? Qt.AscendingOrder : Qt.DescendingOrder
    }
}