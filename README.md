# chromium-latest-Enhanced

This repository is a fork of [scheib/chromium-latest-linux](https://github.com/scheib/chromium-latest-linux) and now the scripts work again and even install Chromium for you, updates with `chromiumup` command and also works for Windows 11.

## Downloads

Check the [release tab](https://github.com/Mealman1551/chromium-latest-Enhanced/releases) for archives with the installation scripts:

* **Windows:** ZIP file
* **Linux:** tar.gz file

For best compatibility, use the installation scripts below.

## Linux (Recommended)

**Install:**

```bash
wget -qO- https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install.sh | bash
```

**Update:**
when updating close all chromium instances
```bash
chromiumup
```

**Remove:**

```bash
wget -qO- https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/remove.sh | bash
```

## Windows
> [!note]
> **Note for Windows 10 users:** To run `install-windows.ps1` and `chromiumup` correctly, you need to download the script locally and run it manually. Windows 11 works fine with the standard PowerShell.


**Install:**

```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install-windows.ps1 | iex
```

**Update:**
when updating close all chromium instances
```powershell
chromiumup
```

**Uninstall:**

```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/uninstall-windows.ps1 | iex
```
### Notes

After installation do a reboot, both Linux as Windows need to initialize the `chromiumup` command, this is done with restarting the device.


### How it works (Windows)

1. **Install**
   The installer downloads the latest Chromium snapshot, extracts it to `%LOCALAPPDATA%\Chromium\Application`, and creates desktop and Start Menu shortcuts. It also sets up the `chromiumup` command and stores the installer script in `%LOCALAPPDATA%\Chromium`.

2. **Update**
   Running `chromiumup` executes the saved installer script, replacing Chromium with the latest version while keeping your user data intact.

3. **Uninstall**
   The uninstaller removes Chromium, shortcuts, the installer script, the `chromiumup` command, and optionally user data. It also cleans up the alias in your PowerShell profile.

### Notes:

- No admin rights are required.
- A reboot is recommended after installation to initialize the `chromiumup` command properly.

## License

[Apache 2.0](/LICENSE)

---

###### &copy; 2025 Mealman1551
