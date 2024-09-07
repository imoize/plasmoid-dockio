function endAll() {
    fetchTimer.stop();
    main.killProgressBar();
    dockerCommand.executable.endAll();
}

function errorRaised(err, message, icon) {
    timer.start();
    dockerCommand.executable.endAll();
    // statusMessage = i18n(message);
    error = i18n(err);
    statusIcon = icon ? icon : "dockio-error";
}

//Util functions
function notificationInstall() {
    let notifypath = "~/.local/share/knotifications6/dockio.notifyrc"
    let notifycontent = `
[Global]
IconName=dockio-icon
Comment=Dockio

[Event/sound]
Name=Sound popup
Comment=Popup and Sound options enabled
Action=Popup|Sound
Sound=message-new-instant.ogg`
    dockerCommand.executable.exec("mkdir -p ~/.local/share/knotifications6/", (_, _, _, _) => { })
    dockerCommand.executable.exec("echo \'" + notifycontent + "\' > " + notifypath, (_, _, _, _) => { })
}

function invokeDelayTimerCallback(callback) {
    if (typeof delayTimerCallback === "function") {
        delayTimerCallback(callback);
    } else {
        if (cfg.debug) console.log("delayTimerCallback is not defined or not a function");
    }
}

class Command {
    constructor(cmd, txt, callback) {
        this.cmd = cmd;
        this.txt = txt;
        this.callback = callback;
    }

    run(...args) {
        const newCmd = this.cmd.replace("{}", args[0]);
        if (cfg.debug) console.log(`New Command: ${newCmd}`);
        this.exec(newCmd, ...args);
    }

    exec(cmd, ...args) {
        dockerCommand.executable.exec(cmd, (_,stdout,stderr,_2) => {
            const match = stdout.trim().match(/Response:(\d+)/);
            const resCode = match ? match[1] : "";
            if (cfg.debug) {
                console.log("Command identifier:", this.txt);
                console.log("Response Code:", resCode || "No match found for response code");
            }
            this.callback(resCode, ...args, stdout);
            if (cfg.debug) console.log(`Command: ${cmd}\nOutput: ${stdout}\nstderr: ${stderr}`);
        });
    }
}

let commands = {
    statDocker: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X GET http://localhost/containers/json",
        "stat-docker", statDockerCallback
    ),
    startDocker: new Command("systemctl start docker.service docker.socket && curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X GET http://localhost/containers/json",
        "start-docker", initDocker
    ),
    stopDocker: new Command("systemctl stop docker.service docker.socket && curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X GET http://localhost/containers/json",
        "stop-docker", initDocker
    ),
    startContainer: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X POST http://localhost/containers/{}/start",
        "start-container", startContainerCallback
    ),
    stopContainer: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X POST http://localhost/containers/{}/stop",
        "stop-container", stopContainerCallback
    ),
    restartContainer: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X POST http://localhost/containers/{}/restart",
        "restart-container", restartContainerCallback
    ),
    deleteContainer: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X DELETE http://localhost/containers/{}",
        "delete-container", deleteContainerCallback
    ),
    inspectContainer: new Command("curl -s --unix-socket /var/run/docker.sock --write-out 'Response:%{http_code}' -X GET http://localhost/containers/{}/json",
        "inspect-container", inspectContainerCallback
    ),
};

function initDocker(resCode) {
    let notifMessage = "";
    let notifTitle = "Docker API";

    if (resCode === "200") {
        initState();
        notifMessage = "Docker engine enabled.";
        invokeDelayTimerCallback(() => {
            notifBuild(notifTitle, notifMessage);
        });
    } else if (resCode !== "200") {
        endAll()
        initState();
        notifMessage = "Docker engine stopped.";
        invokeDelayTimerCallback(() => {
            notifBuild(notifTitle, notifMessage);
        });
    }
}

function initState() {
    commands.statDocker.run();
    dockerCommand.fetchContainers.get();
}

function statDockerCallback(resCode) {
    if (resCode === "200") {
        dockerEnable = true;
        if (cfg.debug) console.log("Docker Enable: " + dockerEnable + " | Docker is running");

        statusMessage = "Docker is running";
        statusIcon = "dockio-rocket";

        updateDockerAction("Stop Docker Engine", "dockio-stop", "stopDocker");
    } else if (resCode !== "200" || resCode === "") {
        endAll()
        dockerEnable = false;
        if (cfg.debug) console.log("Docker Enable: " + dockerEnable + " | Docker is not running");

        statusMessage = "Docker is not running";
        statusIcon = "dockio-error";

        updateDockerAction("Start Docker Engine", "dockio-start", "startDocker");
        containerModel.clear();
    }
}

function updateDockerAction(text, iconName, command) {
    if (typeof dockerAction !== "undefined") {
        dockerAction.text = i18n(text);
        dockerAction.iconName = iconName;
        dockerAction.command = command;
    }
}

function startContainerCallback(resCode, containerId, containerName) {
    let errorMessage = "";
    let notifMessage = "";

    if (resCode === "204") {
        notifMessage = "container started successfully.";
        invokeDelayTimerCallback(dockerCommand.fetchContainers.get());
        notifBuild(containerName, notifMessage);
        if (cfg.debug) console.log(`Container ${containerName} started successfully.`);
    } else if (resCode === "304") {
        errorMessage = `Container ${containerName} is already running.`;
    } else if (resCode === "404") {
        errorMessage = `Error, no such container ${containerName}.`;
    } else if (resCode === "500") {
        errorMessage = "Internal server error.";
    } else {
        errorMessage = `Failed to start container name: ${containerName} id: ${containerId}. Response: ${resCode}`;
    }

    if (cfg.debug) console.log("start container callback error message: " + errorMessage);
    errorRaised(errorMessage);
}

function stopContainerCallback(resCode, containerId, containerName) {
    let errorMessage = "";
    let notifMessage = "";

    if (resCode === "204") {
        notifMessage = "container stopped successfully.";
        notifBuild(containerName, notifMessage);
        invokeDelayTimerCallback(dockerCommand.fetchContainers.get());
        if (cfg.debug) console.log(`Container ${containerName} stopped successfully.`);
    } else if (resCode === "304") {
        errorMessage = `Container ${containerName} is already stopped.`;
    } else if (resCode === "404") {
        errorMessage = `Error, no such container ${containerName}.`;
    } else if (resCode === "500") {
        errorMessage = "Internal server error.";
    } else {
        errorMessage = `Failed to stop container name: ${containerName} id: ${containerId}. Response: ${resCode}`;
    }

    if (cfg.debug) console.log("stop container callback error message: " + errorMessage);
    errorRaised(errorMessage);
}

function restartContainerCallback(resCode, containerId, containerName) {
    let errorMessage = "";
    let notifMessage = "";

    if (resCode === "204") {
        notifMessage = "container restarted successfully.";
        invokeDelayTimerCallback(dockerCommand.fetchContainers.get());
        notifBuild(containerName, notifMessage);
        if (cfg.debug) console.log(`Container ${containerName} restarted successfully.`);
    } else if (resCode === "404") {
        errorMessage = `Error, no such container ${containerName}.`;
    } else if (resCode === "500") {
        errorMessage = "Internal server error.";
    } else {
        errorMessage = `Failed to restart container name: ${containerName} id: ${containerId}. Response: ${resCode}`;
    }

    if (cfg.debug) console.log("restart container callback error message: " + errorMessage);
    errorRaised(errorMessage);
}

function deleteContainerCallback(resCode, containerId, containerName) {
    let errorMessage = "";
    let notifMessage = "";

    if (resCode === "204") {
        notifMessage = "container deleted successfully.";
        invokeDelayTimerCallback(dockerCommand.fetchContainers.get());
        notifBuild(containerName, notifMessage);
        if (cfg.debug) console.log(`Container ${containerName} deleted successfully.`);
    } else if (resCode === "400") {
        errorMessage = "Something went wrong.";
    } else if (resCode === "404") {
        errorMessage = `Error, no such container ${containerName}.`;
    } else if (resCode === "409") {
        errorMessage = `You cannot remove a running container: ${containerName}. Stop the\ncontainer before attempting removal or force remove.`;
    } else if (resCode === "500") {
        errorMessage = "Internal server error.";
    } else {
        errorMessage = `Failed to delete container name: ${containerName} id: ${containerId}. Response: ${resCode}`;
    }

    if (cfg.debug) console.log("delete container callback error message: " + errorMessage);
    errorRaised(errorMessage);
}

function inspectContainerCallback(resCode, containerId, containerName, stdout) {
    let errorMessage = "";

    if (resCode === "200") {
        const cleanStdout = stdout.replace(/Response:\d{3}/, '').trim();
        const jsonObject = JSON.parse(cleanStdout);
        const inspectText = JSON.stringify(jsonObject, null, 2);
        containerOptPage.containerInspectText.text = inspectText;
    } else if (resCode === "404") {
        errorMessage = `Error, no such container ${containerName}.`;
    } else if (resCode === "500") {
        errorMessage = "Internal server error.";
    } else {
        errorMessage = `Failed to restart container name: ${containerName} id: ${containerId}. Response: ${resCode}`;
    }
    if (cfg.debug) console.log("inspect container callback error message: " + errorMessage);
    errorRaised(errorMessage);
}

function notifBuild(containerName, notifMessage) {
    if (showNotification && containerName !== "Docker API") {
        notifTitle = "Container: " + containerName;
        notifText = notifMessage;
        notif.sendEvent();
    } else if (showNotification && containerName === "Docker API") {
        notifTitle = "Docker API";
        notifText = notifMessage;
        notif.sendEvent();
    }
}