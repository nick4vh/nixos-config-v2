# nixos-config/modules/desktops/gnome.nix
{ config, pkgs, lib, ... }:

{
  # GNOME Desktop Umgebung
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    # Display Manager: GDM wird für GNOME empfohlen
    displayManager.gdm = {
      enable = true;
      wayland = true; # GNOME standardmäßig mit Wayland starten
      # Optional: GDM Theme (schwieriger zu themen als SDDM)
    };
    # Deaktiviere SDDM, falls es von einem anderen Modul aktiviert wurde
    displayManager.sddm.enable = lib.mkForce false;
  };

  # Pakete spezifisch für GNOME
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks            # Einstellungs-Tool für GNOME
    gnomeExtensions.appindicator  # Für Tray-Icons (AppIndicator Support)
    gnomeExtensions.user-themes   # Ermöglicht das Setzen von Shell-Themes über Tweaks
    # gnomeExtensions.dash-to-dock # Beliebte Erweiterung für ein Dock
    # gnomeExtensions.gsconnect     # KDE Connect / Smartphone Integration für GNOME (wird in hm-nick-packages.nix verwaltet)
    gnome.gnome-shell-extensions  # Paket für grundlegende Erweiterungsverwaltung
    gnome.nautilus-python         # Für Nautilus-Erweiterungen
    # gnome-console               # Neues Terminal für GNOME (ersetzt gnome-terminal)
    # gnome-text-editor           # Neuer Texteditor (ersetzt gedit)
    # gnome.gnome-sushi           # Dateivorschau für Nautilus (Leertaste)
    # dconf-editor                # Zum Bearbeiten von dconf-Einstellungen (fortgeschritten)
  ];

  # DConf ist zentral für GNOME-Einstellungen
  programs.dconf.enable = true;

  # Wayland-spezifische Einstellungen für GNOME (meist schon gut konfiguriert)
  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf config.services.xserver.displayManager.gdm.wayland {
      # MOZ_ENABLE_WAYLAND = "1"; # Für Firefox Wayland (global in common.nix)
      # NIXOS_OZONE_WL = "1"; # Für Electron Apps (global in common.nix)
    })
  ];

  # NetworkManager (wird von GNOME erwartet und in common.nix global aktiviert)
  # networking.networkmanager.enable = true;

  # GNOME spezifische Dienste
  services.gnome.gnome-keyring.enable = true; # Passwortspeicher
  # services.gnome.gnome-remote-desktop.enable = true; # Für RDP/VNC Zugriff auf die GNOME-Session
  services.gnome.evolution-data-server.enable = true; # Für Kalender, Kontakte etc. (auch von Evolution verwendet)
  # services.gnome.tracker.enable = true; # Dateisuche und -indizierung (kann ressourcenintensiv sein)
  # services.gnome.tracker-miners.enable = true; # Miner für Tracker

  # XDG Portale für Flatpak, Screensharing etc.
  xdg.portal = {
    enable = true; # Wird in common.nix oder flatpak.nix global aktiviert
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # GNOME-spezifisches Portal
      # xdg-desktop-portal-gtk # Allgemeines GTK-Portal (oft schon Abhängigkeit)
    ];
    # gtkUsePortal = true; # Zwingt GTK-Dateidialoge, Portale zu verwenden
  };

  # Optional: Automatische Anmeldung für den Benutzer 'nick' (mit Vorsicht verwenden)
  # services.xserver.displayManager.autoLogin = {
  #   enable = true;
  #   user = "nick";
  # };

  # Deaktiviere PCManFM, falls es von LXDE/LXQt Modulen kommt und Konflikte verursacht
  # programs.pcmanfm.enable = lib.mkForce false;
}
