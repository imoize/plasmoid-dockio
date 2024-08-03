import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: dockerCommand
    property alias executable: executable
    property alias fetchTimer: fetchTimer
    property alias fetchContainers: fetchContainers
    property int progressBar: 0 // Reference to the progress bar

    signal updateProgressBar() // Signal to update the progress bar
    signal stopProgressBar() // Signal to stop the progress bar

    function killProgressBar() {
        stopProgressBar();
    }

    Timer {
        id: fetchTimer
        interval: cfg.fetchContainerInterval * 1000
        repeat: true
        running: dockerEnable
        onTriggered: {
            if (dockerEnable) {
                fetchContainers.get()
                if (cfg.showProgressBar) {
                    updateProgressBar() // Emit the signal to update the progress bar
                }
            } else {
                stopProgressBar()
            }
        }
    }

    Plasma5Support.DataSource {
        id: fetchContainers
        engine: "executable"
        connectedSources: []
        interval: {
            if (dockerEnable) {
                1000
            } else {
                0
            }
        }
        
        onNewData: (sourceName, data) => {
            var stdout = data.stdout
            containerModel.clear();
            const containers = JSON.parse(stdout);

            containers.forEach(container => {
                const containerName = container.Names[0].substring(1)
                const containerId = container.Id;
                const containerImage = container.Image;
                const containerState = container.State;
                const containerStatus = container.Status;
                const containerInfo = container;

                containerModel.append({
                    "containerName": containerName,
                    "containerId": containerId,
                    "containerImage": containerImage,
                    "containerState": containerState,
                    "containerStatus": containerStatus,
                    "containerInfo": JSON.stringify(containerInfo, null, 2)
                });
            });
            disconnectSource(sourceName)
        }

        function get() {
            var cmd = "curl --unix-socket /var/run/docker.sock http://localhost/containers/json?all=true"
            connectSource(cmd)
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var cmd = sourceName
            // var out = data["stdout"].replace(/\u001b\[[0-9;]*[m|K]/g, '')
            var out = data["stdout"]
            var err = data["stderr"]
            var code = data["exit code"]
            var listener = listeners[cmd]

            if (listener) listener(cmd, out, err, code)

            exited(cmd, out, err, code)
            disconnectSource(sourceName)
        }

        signal exited(string cmd, string out, string err, int code)

        property var listeners: ({})

        function exec(cmd, callback) {
            listeners[cmd] = execCallback.bind(executable, callback)
            if (cfg.debug) console.log("Running command:", cmd)
            connectSource(cmd)
        }

        function endAll(){
            for( var proc in listeners ){
                delete listeners[proc]
                disconnectSource(proc)
                killProgressBar()
            }
        }

        function execCallback(callback, cmd, out, err, code) {
            delete listeners[cmd]
            if (callback) callback(cmd, out, err, code)
        }
    }
}