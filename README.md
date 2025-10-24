# chromium-latest-Enhanced

This repository is a fork of [scheib/chromium-latest-linux](https://github.com/scheib/chromium-latest-linux) and now the scripts work again and even install Chromium for you, updates with `chromiumup` command and also works for Windows.

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

```bash
chromiumup
```

**Remove:**

```bash
wget -qO- https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/remove.sh | bash
```

## Windows

**Install:**

```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/install-windows.ps1 | iex
```

**Update:**

```powershell
chromiumup
```

**Uninstall:**

```powershell
irm https://raw.githubusercontent.com/Mealman1551/chromium-latest-Enhanced/refs/heads/master/uninstall-windows.ps1 | iex
```

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

© 2025 Mealman1551
