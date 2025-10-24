# chromium-latest-Enhanced
This repository is a fork of [scheib/chromium-latest-linux](https://github.com/scheib/chromium-latest-linux)

This repo also works for Windows.

To get started check the [release tab](https://github.com/Mealman1551/chromium-latest-Enhanced/releases), and donwload the zip for 
Windows and the tar.gz for Linux.

But even better is to run the commands below for maximal compatibility.

### Linux (Best support and more features)

Install
```bash
wget -qO- https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install.sh | bash
```

To update Chromium type: `chromiumup`


Remove
```bash
wget -qO- https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/remove.sh | bash
```

### Windows

Install
```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install-windows.ps1 | iex
```

To update Chromium type:
```powershell
chromiumup
```

Uninstall:
```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/uninstall-windows.ps1 | iex
```
### Notes

After installation do a reboot, both Linux as Windows need to initialize the `chromium` command, this is done with restarting the device.


###### &copy; 2025 Mealman1551
