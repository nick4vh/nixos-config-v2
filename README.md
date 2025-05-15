# Meine NixOS Konfiguration

Diese Konfiguration verwaltet mehrere NixOS-Systeme und Desktop-Umgebungen über Flakes.

## Struktur

- `flake.nix`: Haupt-Flake-Datei. Definiert Inputs (nixpkgs, home-manager, etc.) und Outputs (Systemkonfigurationen).
- `hosts/`: Host-spezifische Konfigurationen (Hardware, Bootloader, Dateisysteme).
  - `host1.nix`: Für Intel + NVIDIA Desktop.
  - `host2.nix`: Für Intel Laptop.
- `modules/`: Wiederverwendbare Konfigurationsmodule.
  - `nixos/`: Systemweite Module.
    - `common.nix`: Gemeinsame Basiskonfiguration für alle Hosts.
    - `hardware/`: Hardware-spezifische Module (intel.nix, nvidia.nix).
    - `services/`: Module für Systemdienste (Audio, Bluetooth, Drucker, Firewall, etc.).
    - `security.nix`: Sicherheitsrelevante Einstellungen.
    - `gaming.nix`: Gaming-spezifische Optimierungen und Pakete.
  - `home-manager/`: Benutzerkonfigurationen mit Home Manager.
    - `nick/`: Konfiguration für den Benutzer `nick`.
      - `default.nix`: Haupt-Home-Manager-Datei für Nick.
      - `packages.nix`: Liste der von Nick installierten Pakete.
      - `theming.nix`: Theme-, Icon- und Schriftarteinstellungen.
      - `shells.nix`: Konfiguration für Zsh und Fish.
      - `programs/`: (Optional) Konfigurationen für spezifische Programme wie Firefox, Git, etc.
  - `desktops/`: Module für Desktop-Umgebungen (KDE, GNOME, Hyprland).
- `overlays/`: (Optional) Eigene Paket-Overlays oder Modifikationen.
- `README.md`: Diese Anleitung.

## Voraussetzungen

1.  **NixOS Installation:** Eine lauffähige NixOS-Grundinstallation. Der Installer erstellt typischerweise eine initiale `/etc/nixos/configuration.nix` und `/etc/nixos/hardware-configuration.nix`.
2.  **Flakes aktiviert:** Flakes müssen in Ihrer Nix-Installation aktiviert sein. Dies geschieht meist durch Setzen von `experimental-features = nix-command flakes` in `nix.conf` (systemweit oder pro Benutzer) und Verwendung eines Nix-Pakets, das Flakes unterstützt (z.B. `nixFlakes` in `common.nix`).
3.  **Git:** Git wird benötigt, um dieses Repository zu klonen.

## Installation / Anwendung

1.  **Konfiguration kopieren/klonen:**
    Klonen Sie dieses Repository auf Ihr System, z.B. nach `~/nixos-config` oder `/etc/nixos/nixos-config` (wenn Sie es systemweit verwalten möchten).
    ```bash
    git clone https://github.com/nick4vh/nixos-config-v2 ~/nixos-config
    cd ~/nixos-config
    ```

2.  **Hardware-Konfiguration anpassen:**
    * Die Dateien `hosts/host1.nix` und `hosts/host2.nix` enthalten Platzhalter für Dateisysteme und Bootloader-Einstellungen.
    * **Wichtig:** Kopieren Sie den relevanten Inhalt Ihrer bei der NixOS-Installation generierten `/etc/nixos/hardware-configuration.nix` (insbesondere `fileSystems` und `swapDevices`) in die passende Host-Datei (z.B. `hosts/host1.nix`). Passen Sie `boot.loader.grub.device` an Ihre Festplatte an (z.B. `/dev/sda`, `/dev/nvme0n1`).
    * Stellen Sie sicher, dass die Partitionierung (`/dev/sda1` für Root, `/dev/sda2` für EFI-Boot) Ihren Gegebenheiten entspricht oder passen Sie die Pfade in den Host-Dateien an.

3.  **System erstmalig bauen und wechseln:**
    Führen Sie den folgenden Befehl aus, um Ihr System mit der neuen Flake-Konfiguration zu bauen und zu aktivieren. Ersetzen Sie `<hostname>-<desktop>` mit dem gewünschten Ziel aus `flake.nix` (z.B. `host1-kde`).
    ```bash
    # Vom Verzeichnis ~/nixos-config
    sudo nixos-rebuild switch --flake .#host1-kde
    ```
    Oder für Host2 mit GNOME:
    ```bash
    sudo nixos-rebuild switch --flake .#host2-gnome
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
    # Beispiel: sudo nixos-rebuild switch --flake .#host1-gnome
    ```
    Dies erstellt eine neue Generation Ihres Systems. Sie können über das GRUB-Menü beim Booten zu früheren Generationen zurückkehren.

* **Nur Home-Manager Konfiguration aktualisieren:**
    Wenn Sie nur Änderungen in `modules/home-manager/nick/` vorgenommen haben und diese testen möchten, ohne ein komplettes System-Rebuild (obwohl `nixos-rebuild switch` dies auch tut):
    ```bash
    cd ~/nixos-config
    home-manager switch --flake .#nick@<hostname>
    # Beispiel: home-manager switch --flake .#nick@host1
    ```
    Die Aliase `nrs` (NixOS Rebuild Switch) und `hms` (Home Manager Switch) sind in `shells.nix` definiert, um dies zu vereinfachen.

## Auswahl der Desktop-Umgebung

* **Über GRUB (empfohlen für getrennte Konfigurationen):**
    Die `flake.nix` ist so strukturiert, dass Sie für jede Host/Desktop-Kombination einen eigenen Output haben (z.B. `host1-kde`, `host1-gnome`). Wenn Sie `sudo nixos-rebuild switch --flake .#host1-kde` ausführen und später `sudo nixos-rebuild switch --flake .#host1-gnome`, erscheinen beide als separate Generationen im GRUB-Bootmenü. Sie wählen dann beim Start die gewünschte Systemkonfiguration. Dies ist der sauberste Weg, da jede Konfiguration explizit ist.

* **Über den Login-Manager (Display Manager - SDDM/GDM):**
    Wenn Sie möchten, dass KDE, GNOME und Hyprland *gleichzeitig* in einer einzigen Systemgeneration installiert sind und Sie beim Login im Display Manager auswählen können:
    1.  Erstellen Sie einen neuen Output in `flake.nix`, der alle gewünschten Desktop-Module importiert:
        ```nix
        # ... in flake.nix, z.B. für host1
        host1-multi-desktop = mkSystem {
          hostname = "host1";
          currentSystemName = "host1-multi-desktop"; # Wichtig für Home Manager Unterscheidung
          modules = [
            ./modules/desktops/kde.nix
            ./modules/desktops/gnome.nix
            ./modules/desktops/hyprland.nix
            # Stellen Sie sicher, dass nur *ein* Display Manager dominiert.
            # Die Desktop-Module verwenden lib.mkDefault oder lib.mkForce, um dies zu steuern.
            # Ggf. hier explizit einen DM setzen und andere deaktivieren:
            # { services.xserver.displayManager.sddm.enable = true; }
            # { services.xserver.displayManager.gdm.enable = lib.mkForce false; }
          ];
        };
        ```
    2.  Bauen Sie dieses System: `sudo nixos-rebuild switch --flake .#host1-multi-desktop`
    3.  Nach dem Neustart können Sie im Login-Manager (SDDM oder GDM, je nachdem welcher aktiv ist) die gewünschte Desktop-Session (Plasma, GNOME, Hyprland) auswählen.

## Gemeinsame Nutzerdaten und Konfigurationen

Home Manager (`modules/home-manager/nick/`) stellt sicher, dass der Benutzer `nick` auf allen Hosts und über alle Desktop-Umgebungen hinweg dieselben Basiskonfigurationen, Pakete und Themes (wo anwendbar und konfiguriert) erhält. Desktop-spezifische Anpassungen können in den Home-Manager-Modulen über Bedingungen (z.B. `if isKDE then ...`) vorgenommen werden.

## Secure Boot

Secure Boot Unterstützung ist rudimentär angedeutet (`boot.loader.secureBoot.enable`). Eine vollständige Implementierung erfordert manuelle Schlüsselgenerierung, -registrierung im UEFI und Signierung des Bootloaders/Kernels (z.B. mit `sbctl` oder `lanzaboote`). Dies ist ein fortgeschrittenes Thema und für den Anfang wird empfohlen, Secure Boot im UEFI/BIOS zu deaktivieren, bis die Basiskonfiguration stabil läuft.

## Kernel-Auswahl

Der Standard-Kernel von NixOS wird verwendet. Um einen anderen Kernel (z.B. `linuxPackages_zen`) zu nutzen, kommentieren Sie die entsprechende Zeile in der Host-spezifischen Konfiguration (`hosts/*.nix`) ein und passen Sie sie an:
`boot.kernelPackages = pkgs.linuxPackages_zen;` (oder `_latest`, `_xanmod`, etc.)
NixOS stellt sicher, dass externe Module wie NVIDIA-Treiber mit dem gewählten Kernel kompatibel sind.

## Klassische Konfiguration (ohne Flakes)

Obwohl Flakes für diese Komplexität dringend empfohlen werden, hier ein grober Hinweis zur Anpassung an eine klassische Konfiguration (`/etc/nixos/configuration.nix`):

1.  Kopieren Sie die Verzeichnisse `modules/` und `hosts/` (oder deren relevanten Inhalt) nach `/etc/nixos/`.
2.  In Ihrer `/etc/nixos/configuration.nix`:
    ```nix
    { config, pkgs, ... }:

    let
      # Manuell definieren, welcher Host und welche Desktops gebaut werden sollen
      currentHostName = "host1"; # oder "host2"
      # Für Home Manager: Diese Variablen müssten anders übergeben werden
      # specialArgsForHM = { inherit pkgs; hostname = currentHostName; currentSystem = "${currentHostName}-kde"; /* ... inputs ... */ };

      # Desktop-Module auswählen
      activeDesktopModules = [
        ./modules/desktops/kde.nix
        # ./modules/desktops/gnome.nix
      ];
    in
    {
      imports =
        [
          ./hardware-configuration.nix # Ihre generierte Hardware-Konfiguration
          ./hosts/${currentHostName}.nix    # Host-spezifische Einstellungen
        ]
        # Gemeinsame Module und Services direkt importieren
        ++ (map (path: import path) [
             ./modules/nixos/common.nix
             ./modules/nixos/services/audio.nix
             ./modules/nixos/services/bluetooth.nix
             ./modules/nixos/services/cups.nix
             ./modules/nixos/services/flatpak.nix
             ./modules/nixos/services/firewall.nix
             ./modules/nixos/services/ssd.nix
             ./modules/nixos/services/virtualization.nix
             ./modules/nixos/security.nix
             ./modules/nixos/gaming.nix
           ])
        ++ activeDesktopModules # Ausgewählte Desktop-Module
        ++ [
             # Home Manager Modul für NixOS (erfordert Einbindung von Home Manager als Plugin)
             # z.B. über <home-manager/nixos>
             # ({ pkgs, ... }: {
             #   home-manager.useGlobalPkgs = true;
             #   home-manager.useUserPackages = true;
             #   home-manager.users.nick = import ./modules/home-manager/nick/default.nix specialArgsForHM;
             # })
           ];

      # Nixpkgs Konfiguration (falls Overlays verwendet werden)
      # nixpkgs.overlays = [ (import ./overlays/default.nix) ];

      system.stateVersion = "23.11"; # Anpassen
    }
    ```
    Diese Methode ist deutlich umständlicher für die Verwaltung von Varianten und Home Manager. Flakes sind hier klar überlegen. Die Übergabe von `inputs` und `specialArgs` an die Module ist mit Flakes wesentlich eleganter.

