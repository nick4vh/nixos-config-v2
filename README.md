# Meine NixOS Konfiguration

Diese Konfiguration verwaltet mehrere NixOS-Systeme und Desktop-Umgebungen über Flakes.

## Struktur

- `flake.nix`: Haupt-Flake-Datei.
- `hosts/`: Host-spezifische Konfigurationen.
  - `host1/`: Konfiguration für Host1 (Intel + NVIDIA Desktop).
    - `default.nix`: Hauptkonfigurationsdatei für Host1, importiert `hardware-configuration.nix` und spezifische Hardware-Module.
    - `hardware-configuration.nix`: **Diese Datei muss vom Benutzer hierher kopiert werden.** Sie wird bei der NixOS-Installation generiert.
  - `host2/`: Konfiguration für Host2 (Intel Laptop).
    - `default.nix`: Hauptkonfigurationsdatei für Host2.
    - `hardware-configuration.nix`: **Diese Datei muss vom Benutzer hierher kopiert werden.**
- `modules/`: Wiederverwendbare Konfigurationsmodule (Systemdienste, Benutzerkonfigurationen, Desktop-Umgebungen etc.).
  - `nixos/`: Systemweite Module.
  - `home-manager/`: Benutzerkonfigurationen mit Home Manager.
  - `desktops/`: Module für Desktop-Umgebungen.
- `overlays/`: (Optional) Eigene Paket-Overlays.
- `README.md`: Diese Anleitung.

## Voraussetzungen

1.  **NixOS Installation:** Eine lauffähige NixOS-Grundinstallation. Der Installer erstellt `/etc/nixos/configuration.nix` und `/etc/nixos/hardware-configuration.nix`.
2.  **Flakes aktiviert:** Siehe NixOS-Dokumentation.
3.  **Git:** Zum Klonen dieses Repositories.

## Installation / Anwendung

1.  **Konfiguration kopieren/klonen:**
    Klonen Sie dieses Repository, z.B. nach `~/nixos-config`.
    ```bash
    git clone https://github.com/nick4vh/nixos-config-v2 ~/nixos-config
    cd ~/nixos-config
    ```

2.  **Hardware-Konfiguration einfügen:**
    * **Für jeden Host (z.B. host1):** Kopieren Sie die bei der NixOS-Installation für diesen Host generierte Datei `/etc/nixos/hardware-configuration.nix` in das entsprechende Verzeichnis Ihrer geklonten Konfiguration.
        * Für `host1`: Kopieren nach `~/nixos-config/hosts/host1/hardware-configuration.nix`
        * Für `host2`: Kopieren nach `~/nixos-config/hosts/host2/hardware-configuration.nix`
    * Die Dateien `hosts/host1/default.nix` und `hosts/host2/default.nix` importieren dann diese `hardware-configuration.nix`.
    * Überprüfen Sie die `default.nix` in den Host-Verzeichnissen. Bootloader-Einstellungen (`boot.loader.grub.device`) und Dateisysteme werden primär aus der `hardware-configuration.nix` erwartet. Falls dort nicht alles Nötige steht (z.B. `efiSupport`), können die Einstellungen in `default.nix` als Ergänzung oder Überschreibung dienen.

3.  **System erstmalig bauen und wechseln:**
    Führen Sie den folgenden Befehl aus, um Ihr System mit der neuen Flake-Konfiguration zu bauen und zu aktivieren. Ersetzen Sie `<hostname>-<desktop>` mit dem gewünschten Ziel aus `flake.nix` (z.B. `host1-kde`).
    ```bash
    # Vom Verzeichnis ~/nixos-config
    sudo nixos-rebuild switch --flake .#host1-kde
    ```

4.  **Passwort für Benutzer `nick` setzen:**
    Nach dem ersten erfolgreichen `nixos-rebuild switch` und einem Neustart (oder wenn die Session neu geladen wurde), setzen Sie das Passwort für den Benutzer `nick`:
    ```bash
    sudo passwd nick
    ```

## System aktualisieren und Desktop-Umgebung wechseln

* **Konfiguration ändern:** Bearbeiten Sie die Dateien in diesem Repository.
* **Änderungen anwenden:**
    ```bash
    cd ~/nixos-config
    sudo nixos-rebuild switch --flake .#<hostname>-<desktop>
    ```
    Die Aliase `nrs` (NixOS Rebuild Switch) und `hms` (Home Manager Switch) sind in `shells.nix` definiert.

## Auswahl der Desktop-Umgebung

* **Über GRUB (empfohlen für getrennte Konfigurationen):** Bauen Sie spezifische Targets wie `host1-kde` oder `host1-gnome`. Diese erscheinen als separate Generationen im GRUB-Menü.
* **Über den Login-Manager (Display Manager - SDDM/GDM):** Erstellen Sie ein "Multi-Desktop"-Target in `flake.nix`, das alle gewünschten Desktop-Module importiert. Wählen Sie dann die Session beim Login.

## Gemeinsame Nutzerdaten und Konfigurationen

Home Manager (`modules/home-manager/nick/`) stellt sicher, dass der Benutzer `nick` konsistente Konfigurationen, Pakete und Themes erhält.

## Secure Boot & Kernel-Auswahl

Siehe vorherige Version der README für Details. Die grundlegenden Mechanismen bleiben gleich.

## Klassische Konfiguration (ohne Flakes)

Die Anpassung an eine klassische Konfiguration wird durch diese Änderung noch etwas direkter, da die `hardware-configuration.nix` nun explizit Teil der Host-Definition ist. Der Importpfad in einer klassischen `/etc/nixos/configuration.nix` würde dann z.B. auf `./hosts/host1/default.nix` zeigen (vorausgesetzt, die Struktur liegt relativ zu `/etc/nixos/`). Flakes bleiben aber für die Verwaltung dieser Komplexität überlegen.
