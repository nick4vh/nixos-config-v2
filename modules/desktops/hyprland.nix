# nixos-config/modules/desktops/hyprland.nix
{ config, pkgs, lib, inputs, ... }:

{
  # Hyprland Wayland Compositor
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland; # Verwendet den Input aus flake.nix
    # package = pkgs.hyprland; # Alternative, wenn die Version in nixpkgs aktuell genug ist
    xwayland.enable = true; # Für X11-Anwendungen unter Wayland
    # Optional: Zusätzliche Plugins oder Konfigurationen
    # plugins = [ inputs.hyprland-plugins.packages.${pkgs.system}.hyprsome ];
    # portalPackage = pkgs.xdg-desktop-portal-hyprland; # Stellt sicher, dass der Hyprland-Portal verwendet wird
  };

  # Display Manager
  # SDDM oder GDM können Hyprland starten. Alternativ ein Greeter wie greetd oder direkter Start.
  # Hier verwenden wir SDDM als Standard, falls es nicht von einem anderen DE-Modul überschrieben wird.
  services.xserver.displayManager.sddm = {
    enable = lib.mkDefault true; # Aktiviere SDDM, falls nicht schon durch KDE
    wayland.enable = lib.mkDefault true;
  };
  # Es muss eine Hyprland Session-Datei für SDDM/GDM vorhanden sein.
  # NixOS' Hyprland-Modul erstellt diese normalerweise unter /run/current-system/sw/share/wayland-sessions/hyprland.desktop

  # Notwendige Pakete für eine funktionierende Hyprland-Umgebung
  environment.systemPackages = with pkgs; [
    # Hyprland spezifische Tools (einige sind optional, je nach Setup)
    # hyprpaper    # Wallpaper-Daemon für Hyprland
    # hyprpicker   # Farbpicker
    # hyprshot     # Screenshot-Tool (oder grim + slurp)
    # hyprlock     # Sperrbildschirm (oder swaylock-effects)
    # hypridle     # Inaktivitäts-Daemon

    # Allgemeine Wayland-Tools
    rofi-wayland # Anwendungsstarter (oder wofi)
    waybar       # Statusleiste (oder eine andere wie eww)
    swaybg       # Für Hintergrundbilder, falls hyprpaper nicht verwendet wird
    swayidle     # Für Inaktivität und Sperrbildschirm-Trigger
    swaylock-effects # Sperrbildschirm mit Effekten
    mako         # Benachrichtigungsdaemon (oder dunst)
    wl-clipboard # Werkzeuge für die Wayland-Zwischenablage (wl-copy, wl-paste)
    cliphist     # Zwischenablagen-Manager für Wayland (speichert wl-clipboard Historie)
    wlr-randr    # Für Display-Konfiguration (ähnlich xrandr für X11)
    brightnessctl # Helligkeitssteuerung für Bildschirm und Tastatur
    pamixer      # Kommandozeilen-Mixer für PulseAudio/PipeWire
    grim         # Screenshot-Tool für Wayland
    slurp        # Zum Auswählen von Bereichen für grim
    imv          # Einfacher Bildbetrachter für Wayland/X11
    mpv          # Mediaplayer mit guter Wayland-Unterstützung

    # Polkit Agent (wichtig für Berechtigungen von GUI-Anwendungen)
    # lxqt.lxqt-policykit # Leichtgewichtiger Polkit-Agent
    polkit_gnome # GNOME Polkit Agent (funktioniert auch gut außerhalb von GNOME)

    # Netzwerkmanagement-Applet (für Waybar etc.)
    networkmanagerapplet # nm-applet

    # Terminal (Alacritty ist in User-Paketen, hier als System-Fallback oder falls global gewünscht)
    # alacritty

    # Schriftarten und Icons (werden primär über Home Manager verwaltet)
    # noto-fonts-emoji # Für Emojis
    # papirus-icon-theme # Für Icons in Rofi/Waybar

    # dbus (wird meist automatisch aktiviert, aber zur Sicherheit)
    dbus
  ];

  # Umgebungsvariablen für Hyprland und Wayland-Anwendungen
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland"; # Für einige Anwendungen relevant
    XDG_SESSION_TYPE = "wayland";
    # MOZ_ENABLE_WAYLAND = "1"; # Global in common.nix
    # QT_QPA_PLATFORM = "wayland;xcb"; # Global in common.nix oder spezifischer hier
    # SDL_VIDEODRIVER = "wayland";
    # _JAVA_AWT_WM_NONREPARENTING = "1"; # Für Java Swing/AWT
    # GDK_BACKEND = "wayland,x11"; # GTK-Anwendungen (bevorzugt Wayland)
    # XCURSOR_THEME = "Bibata-Modern-Classic"; # Cursor-Theme (wird auch von Home Manager gesetzt)
    # XCURSOR_SIZE = "24";
  };

  # PipeWire und WirePlumber werden bereits in `audio.nix` global aktiviert.
  # XDG Portale für Flatpak, Screensharing etc.
  xdg.portal = {
    enable = true; # Global in common.nix oder flatpak.nix
    # Der xdg-desktop-portal-hyprland sollte bevorzugt werden.
    # xdg-desktop-portal-wlr ist ein Fallback.
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      # xdg-desktop-portal-wlr # Fallback, falls hyprland-Portal nicht alles abdeckt
      xdg-desktop-portal-gtk   # Für GTK-Dialoge
    ];
    # config.xdg.portal.gtkUsePortal = true; # Optional
  };

  # NetworkManager für Netzwerkverwaltung (z.B. mit nm-applet in Waybar)
  # networking.networkmanager.enable = true; # Global in common.nix

  # Konfiguration für Hyprland (~/.config/hypr/hyprland.conf)
  # Diese sollte über Home Manager verwaltet werden.
  # home-manager.users.nick = { ... programs.hyprland.configFile = ./path/to/hyprland.conf; ... };
  # Oder durch Symlinks im Home-Manager Modul von `nick`.

  # Polkit (PolicyKit) Regeln, falls nötig
  # security.polkit.enable = true; # Stellt sicher, dass Polkit läuft

  # Udev-Regeln für Eingabegeräte (z.B. Touchpad-Gesten, spezielle Mäuse)
  # services.udev.extraRules = ''
  #   # Beispiel:
  #   # KERNEL=="event[0-9]*", ATTRS{name}=="*SynPS/2 Synaptics TouchPad*", ENV{LIBINPUT_CONFIG_MIDDLE_EMULATION_ENABLED}="1"
  # '';

  # Input Method Editor (IME) für nicht-lateinische Schriften (z.B. Fcitx5)
  # i18n.inputMethod = {
  #   enabled = "fcitx5";
  #   fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk fcitx5-qt ]; # Japanisch, GTK, Qt Integration
  # };
}
