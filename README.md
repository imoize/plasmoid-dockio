# Dockio

Control your docker containers from plasma applet.

> [!NOTE]
> This extension use custom icon, you need to copy contents from icons folder to your theme or local icons folder.

## Features

* List all available containers
* Start, Stop, Restart and Delete containers
* Show containers info
* Inspect containers

## Screenshots

![Main Page](./image/screenshot1.png)
![Opt Page](./image/screenshot2.png)

## Installation

### Build it Yourself

```bash
git clone https://github.com/imoize/plasma-dockio.git dockio
cd dockio
kpackagetool6 -t Plasma/Applet -i package
```

### Icons

```bash
mkdir -p ~/.local/share/icons/hicolor/scalable/status
cp -r ./icons/* ~/.local/share/icons/hicolor/scalable/status/
```

Restart plasmashell
```bash
systemctl --user restart plasma-plasmashell
```

Go to Configure System Tray > Entries > System Services then choose "Show when relevant" or "Always shown"