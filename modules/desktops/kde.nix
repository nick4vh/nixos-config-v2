# nixos-config/modules/desktops/kde.nix
{ config, pkgs, lib, ... }:

{
  # KDE Plasma Desktop Umgebung
  services.xserver = {
    enable = true;
    desktopManager.plasma6 = {
      enable = true;
      # defaultSession = "plasma6-wayland"; # Optional: explizit setzen
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      # theme = "${pkgs.sddm-chili-theme}/share/sddm/themes/chili"; # Optionales Theme
    };
    displayManager.gdm.enable = lib.mkForce false;
  };

  # Pakete für KDE Plasma 6
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.ark
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.spectacle
    kdePackages.kate

    # Integration
    # breeze-gtk
    # breeze-icons

    kdePackages.plasma-browser-integration
    # plasma-firewall

    # Optionales: yakuake, kcalc, filelight, kcharselect etc.
  ];

  # Programme, die für KDE relevant sind
  programs.dconf.enable = true;

  # Qt5-Style Plugins nicht mehr notwendig mit Plasma 6 (optional entfernbar)
  # environment.systemPackages = with pkgs; [ libsForQt5.qtstyleplugin-kvantum ];

  # Plasma 6 ersetzt plasma5.* → Konfiguration wird einfacher
  environment.plasma5.excludePackages = [];

  # Wayland-Einstellungen
  environment.sessionVariables = lib.mkMerge [
    (lib.mkIf config.services.xserver.displayManager.sddm.wayland.enable {
      QT_QPA_PLATFORM = "wayland;xcb";
      # MOZ_ENABLE_WAYLAND = "1";
      # NIXOS_OZONE_WL = "1";
    })
  ];

  # KDE Connect
  programs.kdeconnect = {
    enable = true;
  };

  # XDG Portale für Flatpak, Screensharing etc.
  xdg.portal = {
    enable = true;
    # Nutze **explizit** das neue Qt 6-Portal für KDE
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    # gtkUsePortal = true;
  };
  # Optionales Sound-Theme
  # sound.theme = "freedesktop";
}
