# nixos-config/modules/desktops/kde.nix
{ config, pkgs, lib, ... }:

{
  # KDE Plasma Desktop Umgebung
  services.xserver = {
    enable = true; # Stellt sicher, dass XServer aktiviert ist (auch für Wayland-Sessions mit XWayland)
    desktopManager.plasma5 = {
      enable = true;
      # kdeApplications.enable = true; # Installiert eine breite Palette von KDE-Standardanwendungen.
                                    # Besser gezielt auswählen, was benötigt wird, um das System schlank zu halten.
      # Optional: Wähle zwischen Wayland und X11 Session als Standard
      # defaultSession = "plasmawayland"; # oder "plasma" für X11
    };
    # Display Manager: SDDM wird für Plasma empfohlen
    displayManager.sddm = {
      enable = true;
      wayland.enable = true; # SDDM selbst im Wayland-Modus starten (Plasma Wayland Session wird dann Standard)
      # theme = "catppuccin-mocha-sddm"; # Beispiel SDDM Theme (muss als Paket verfügbar sein)
      # Für Catppuccin SDDM Theme:
      # theme = "${pkgs.catppuccin-sddm.override { variant = "mocha"; }}/share/sddm/themes/catppuccin-mocha";
      # Oder ein anderes Theme aus nixpkgs, z.B.:
      # theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili";
    };
    # Deaktiviere GDM, falls es von einem anderen Modul aktiviert wurde
    displayManager.gdm.enable = lib.mkForce false;
  };

  # Pakete spezifisch für KDE oder die gut integrieren
  environment.systemPackages = with pkgs; [
    # Wichtige KDE-Anwendungen (falls nicht schon durch home.packages abgedeckt)
    kdePackages.dolphin         # Dateimanager
    kdePackages.konsole         # Terminal-Emulator
    kdePackages.ark             # Archivierungswerkzeug
    kdePackages.gwenview        # Bildbetrachter
    kdePackages.okular          # Dokumentenbetrachter (PDF, etc.)
    kdePackages.spectacle       # Screenshot-Tool
    kdePackages.kate            # Fortgeschrittener Texteditor
    # kdePackages.kcalc           # Taschenrechner
    # kdePackages.filelight       # Speicherplatzanalyse
    # kdePackages.kcharselect     # Sonderzeichenauswahl

    # KDE PIM Suite (optional, falls Evolution nicht verwendet wird)
    # kdePackages.kontact
    # kdePackages.kmail
    # kdePackages.korganizer
    # kdePackages.akonadi # Backend für PIM

    # Integration und Theming
    libsForQt5.qtstyleplugin-kvantum # Kvantum SVG-basiertes Style-Plugin für Qt-Anwendungen
    # breeze-gtk # Für konsistentes Aussehen von GTK-Anwendungen unter Plasma
    # breeze-icons # Standard KDE Icons (normalerweise schon dabei)
    # oxygen-icons # Alternatives KDE Icon Set

    # Plasma Browser Integration
    plasma-browser-integration

    # Firewall-GUI für Plasma (wenn firewalld verwendet wird)
    # plasma-firewall # (braucht `services.firewalld.enable = true;`)

    # Weitere nützliche KDE-Tools
    # yakuake # Drop-down Terminal
  ];

  # Programme, die für KDE relevant sind oder gut integrieren
  programs.dconf.enable = true; # Für einige GTK-Anwendungen, die unter KDE laufen

  # Umgebungsvariablen für KDE
  environment.plasma5.excludePackages = with pkgs; [
    # Pakete, die nicht mit der Plasma-Session gestartet werden sollen
    # z.B. wenn man alternative Panels oder App-Launcher verwendet
    # kdePackages.discover # Software Center, falls nicht gewünscht
  ];

  # Wayland-spezifische Einstellungen für KDE
  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf config.services.xserver.displayManager.sddm.wayland.enable {
      # Stellt sicher, dass Qt-Anwendungen Wayland verwenden
      QT_QPA_PLATFORM = "wayland;xcb"; # Wayland bevorzugt, XCB als Fallback
      # MOZ_ENABLE_WAYLAND = "1"; # Für Firefox Wayland (oft automatisch, aber schadet nicht)
      # Für Electron Apps, die Wayland unterstützen sollen (wird in common.nix global gesetzt)
      # NIXOS_OZONE_WL = "1";
    })
  ];

  # NetworkManager für KDE Plasma Applet (wird in common.nix global aktiviert)
  # networking.networkmanager.enable = true;

  # KDE Connect (Smartphone-Integration)
  programs.kdeconnect = {
    enable = true;
    # Firewall-Regeln für KDE Connect werden oft automatisch gehandhabt,
    # wenn `networking.firewall.enable = true` gesetzt ist.
    # Ansonsten müssten Ports 1714-1764 TCP/UDP geöffnet werden.
  };
  # Das Paket `kdePackages.kdeconnect-kde` wird über Home Manager installiert.

  # XDG Portale für Flatpak, Screensharing etc.
  xdg.portal = {
    enable = true; # Wird in common.nix oder flatpak.nix global aktiviert
    extraPortals = [ pkgs.xdg-desktop-portal-kde ]; # KDE-spezifisches Portal
    # gtkUsePortal = true; # Zwingt GTK-Dateidialoge, Portale zu verwenden (kann helfen)
  };

  # Sound-Thema für Plasma (optional)
  # sound.theme = "freedesktop"; # Oder ein anderes installiertes Sound-Theme
  # environment.variables.PLASMA_SOUND_THEME = "my-custom-theme";

  # Konfiguration für KWallet (Passwortspeicher)
  services.kwalletd.enable = true; # Aktiviert den KWallet Daemon
}
