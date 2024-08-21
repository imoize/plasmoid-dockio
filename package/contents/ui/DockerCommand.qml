import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support

Item {
    id: dockerCommand
    property alias executable: executable
    property alias fetchContainers: fetchContainers

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
            }
        }

        function execCallback(callback, cmd, out, err, code) {
            delete listeners[cmd]
            if (callback) callback(cmd, out, err, code)
        }
    }
}