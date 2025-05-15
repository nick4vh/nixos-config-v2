# nixos-config/modules/home-manager/nick/theming.nix
{ pkgs, config, lib, inputs, currentSystem, ... }:

let
  isKDE = lib.strings.hasSuffix "-kde" currentSystem;
  isGNOME = lib.strings.hasSuffix "-gnome" currentSystem;
  isHyprland = lib.strings.hasSuffix "-hyprland" currentSystem;

  # Gewünschtes GTK Theme und Icons
  # Beispiel: Catppuccin (Mocha Variante mit Mauve Akzent)
  catppuccinMochaMauve = pkgs.catppuccin-gtk.override {
    variant = "mocha"; # latte, frappe, macchiato, mocha
    accents = ["mauve"]; # rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
  };
  gtkThemeName = catppuccinMochaMauve.name; #"Catppuccin-Mocha-Standard-Mauve-Dark";
  gtkThemePackage = catppuccinMochaMauve;
  iconThemeName = "Tela-circle-dracula"; # Oder "Papirus-Dark", "Numix-Circle" etc.
  iconThemePackage = pkgs.tela-icon-theme; # Oder pkgs.papirus-icon-theme

in
{
  home.packages = with pkgs; [
    # Schriftarten
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans # Für Chinesisch, Japanisch, Koreanisch
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; }) # Nerd Fonts (Fira Code, JetBrains Mono)

    # Icon Theme
    tela-icon-theme
    # papirus-icon-theme # Alternative oder Ergänzung

    # Cursor Theme
    bibata-cursors # Schönes Cursor-Theme

    # GTK Themes (falls nicht schon durch Abhängigkeiten wie catppuccin-gtk abgedeckt)
    # gnome.adwaita-icon-theme # Standard Adwaita Icons (Fallback)
    # adw-gtk3 # Für Konsistenz von GTK3 Apps mit libadwaita (GNOME)

    # KDE Themes (werden meist über Plasma-Systemeinstellungen oder das KDE-Desktop-Modul gehandhabt)
    # Hier können aber Pakete bereitgestellt werden, z.B. Kvantum Themes oder spezielle KStyle Engines
    # Beispiel für Catppuccin Kvantum Theme (wenn Catppuccin als Input im Flake definiert ist)
    # (inputs.catppuccin-kvantum.packages.${pkgs.system}.default)

    # Kvantum Manager und Themes (SVG-basiertes Theme-Engine für Qt)
    libsForQt5.qtstyleplugin-kvantum # Kvantum Engine
    # kvantum # Kvantum Manager GUI (qt6 version: pkgs.qt6.qt6styleplugins)
    # Beispiel Kvantum Themes:
    # matcha-themes # Enthält auch Kvantum Themes
  ];

  # GTK Theming
  gtk = {
    enable = true;
    font = {
      name = "Noto Sans";
      size = 10;
      # Monospace Schriftart für Anwendungen, die dies nutzen
      # package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; }; # Stellt sicher, dass die Schriftart verfügbar ist
      # name = "FiraCode Nerd Font Mono"; # Wird oft von der Terminal-Konfig überschrieben
    };
    theme = {
      name = gtkThemeName;
      package = gtkThemePackage;
    };
    iconTheme = {
      name = iconThemeName;
      package = iconThemePackage;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic"; # Aus dem bibata-cursors Paket
      package = pkgs.bibata-cursors;
      size = 24;
    };
    # GTK4 spezifische Einstellungen (optional)
    # gtk4.extraConfig = {
    #   gtk-application-prefer-dark-theme = true;
    # };
  };

  # Qt Theming (für Anwendungen außerhalb von KDE oder zur Vereinheitlichung)
  qt = {
    enable = true;
    platformTheme = if isKDE then "kde" else "gtk2"; # "kde", "gnome", "gtk2", "qtct"
    # Style für Qt-Anwendungen. Mit KDE wird dies von Plasma selbst verwaltet.
    # Außerhalb von KDE kann man versuchen, es an GTK anzupassen oder Kvantum zu nutzen.
    style = if isKDE then null # KDE handhabt seinen eigenen Stil
            else if pkgs.stdenv.isLinux then "kvantum" # Kvantum für Qt5/Qt6 wenn nicht KDE
            else "adwaita-dark"; # Fallback
    # Für Qt6:
    # programs.qt6ct.enable = if !isKDE then true else false; # Qt6 Konfigurationstool
    # xsettingsd.enable = if !isKDE then true else false; # Für konsistente Settings über Toolkits hinweg

    # Kvantum Theme setzen (wenn Kvantum als Style gewählt wurde)
    # home.file.".config/Kvantum/kvantum.kvconfig".text = lib.mkIf (!isKDE && pkgs.stdenv.isLinux) ''
    #   [General]
    #   theme=KvCatppuccinMochaMauve # Name des Kvantum-Themes (muss installiert sein)
    # '';
  };

  # dconf Einstellungen für Theming (hauptsächlich für GNOME/GTK)
  # Wird teilweise von gtk Modul oben schon gesetzt, hier für spezifischere dconf keys
  dconf.settings = lib.mkMerge [
    (lib.mkIf (!isKDE) { # Nur wenn nicht KDE aktiv ist, da KDE dies selbst verwaltet
      "org/gnome/desktop/interface" = {
        gtk-theme = gtkThemeName;
        icon-theme = iconThemeName;
        cursor-theme = "Bibata-Modern-Classic";
        font-name = "Noto Sans 10";
        document-font-name = "Noto Sans 10";
        monospace-font-name = "FiraCode Nerd Font Mono 11"; # Beispiel für Monospace
      };
      "org/gnome/desktop/wm/preferences" = {
        theme = gtkThemeName; # Fenstermanager-Theme (für Metacity/Mutter)
      };
    })
    # Weitere dconf Einstellungen...
  ];


  # Schriftkonfiguration für Fontconfig (systemweite Einstellungen)
  fonts.fontconfig = {
    enable = true;
    antialias = true; # Antialiasing aktivieren
    hinting = {
      enable = true;
      style = "hintslight"; # "hintfull", "hintmedium", "hintslight", "hintnone"
    };
    subpixel.rgba = "rgb"; # "rgb", "bgr", "vrgb", "vbgr", "none" (an Monitor anpassen)
    # Standard Schriftfamilien definieren
    defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      monospace = [ "FiraCode Nerd Font Mono" "Noto Sans Mono" ]; # Fallback
      emoji = [ "Noto Color Emoji" ];
    };
    # Optional: Fontconfig Regeln für spezifische Schriftarten oder Aliase
    # localConf = ''
    #   <?xml version="1.0"?>
    #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    #   <fontconfig>
    #     <match target="pattern">
    #       <test qual="any" name="family"><string>mono</string></test>
    #       <edit name="family" mode="assign" binding="strong">
    #         <string>FiraCode Nerd Font Mono</string>
    #       </edit>
    #     </match>
    #   </fontconfig>
    # '';
  };

  # Alacritty Terminal Theming (Beispiel)
  programs.alacritty = {
    enable = true; # Wird in hm-nick-packages.nix als Paket hinzugefügt
    settings = {
      env.TERM = "xterm-256color";
      font = {
        normal = { family = "FiraCode Nerd Font Mono"; style = "Retina"; }; # Oder JetBrainsMono
        bold = { family = "FiraCode Nerd Font Mono"; style = "Bold"; };
        italic = { family = "FiraCode Nerd Font Mono"; style = "Italic"; };
        size = 11;
      };
      window.opacity = 0.90;
      # Catppuccin Mocha Theme für Alacritty
      colors = {
        primary = { background = "0x1e1e2e"; foreground = "0xcdd6f4"; }; # base, text
        cursor = { text = "0x1e1e2e"; cursor = "0xf5e0dc"; }; # base, rosewater
        vi_mode_cursor = { text = "0x1e1e2e"; cursor = "0xb4befe"; }; # base, lavender
        selection = { text = "0x1e1e2e"; background = "0xf5e0dc"; }; # base, rosewater
        search = {
          matches = { foreground = "0x1e1e2e"; background = "0xa6adc8"; }; # base, subtext0
          focused_match = { foreground = "0x1e1e2e"; background = "0xa6e3a1"; }; # base, green
        };
        normal = {
          black = "0x45475a"; red = "0xf38ba8"; green = "0xa6e3a1"; yellow = "0xf9e2af";
          blue = "0x89b4fa"; magenta = "0xf5c2e7"; cyan = "0x94e2d5"; white = "0xbac2de";
        }; # surface1, red, green, yellow, blue, pink, teal, subtext1
        bright = {
          black = "0x585b70"; red = "0xf38ba8"; green = "0xa6e3a1"; yellow = "0xf9e2af";
          blue = "0x89b4fa"; magenta = "0xf5c2e7"; cyan = "0x94e2d5"; white = "0xa6adc8";
        }; # surface2, red, green, yellow, blue, pink, teal, subtext0
      };
    };
  };
}
