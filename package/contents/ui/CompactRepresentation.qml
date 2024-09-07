import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "../Utils.js" as Utils

MouseArea {
    id: compact
    property bool wasExpanded: false
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    hoverEnabled: true
    onPressed: (mouse) => {
        wasExpanded = main.expanded
    }
    onClicked: (mouse) => {
        if(mouse.button == Qt.MiddleButton) {
            Utils.commands["statDocker"].run();
        } else {
            main.expanded = !wasExpanded;
            if(main.expanded  && cfg.fetchOnExpand) {
                Utils.initState();
                main.pop();
            }
            main.pop();
        }
    }

    Kirigami.Icon {
        id: updateIcon
        anchors.fill: parent
        active: compact.containsMouse
        activeFocusOnTab: true
        source: Qt.resolvedUrl("icons/dockio-icon.svg")
        color: {
            if ( error === "" && dockerEnable === true ) {
                Kirigami.Theme.textColor
            } else if ( error !== "" && dockerEnable === true ) {
                Kirigami.Theme.negativeTextColor
            } else if (error === "" && dockerEnable === false ) {
                Kirigami.Theme.disabledTextColor
            } else if (error !== "" && dockerEnable === false ) {
                Kirigami.Theme.negativeTextColor
            }
        }
    }
}

