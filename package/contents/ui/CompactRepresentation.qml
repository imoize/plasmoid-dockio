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
    onPressed: wasExpanded = expanded
    onClicked: (mouse) => {
        if(mouse.button == Qt.MiddleButton) {
            Utils.commands["statDocker"].run();
        } else {
            expanded = !wasExpanded;
            
            if(expanded && cfg.fetchOnExpand) {
                Utils.initState();
                main.pop();
            }
            main.pop();
        }
    }
    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            Plasmoid.activated();
            event.accepted = true;
            break;
        }
    }
    Kirigami.Icon {
        id: updateIcon
        anchors.fill: parent
        active: compact.containsMouse
        activeFocusOnTab: true
        source: "dockio-icon"
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

