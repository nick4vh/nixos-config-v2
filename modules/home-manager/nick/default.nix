# nixos-config/modules/home-manager/nick/default.nix
{ pkgs, config, lib, inputs, hostname, currentSystem, ... }:
# hostname und currentSystem werden von der Flake-Definition übergeben

let
  isKDE = lib.strings.hasSuffix "-kde" currentSystem;
  isGNOME = lib.strings.hasSuffix "-gnome" currentSystem;
  isHyprland = lib.strings.hasSuffix "-hyprland" currentSystem;
in
{
  imports = [
    ./packages.nix
    ./theming.nix
    ./shells.nix
    # Weitere Home-Manager Module hier importieren, z.B. für spezifische Programme
    # ./programs/firefox.nix
    # ./programs/git.nix
    # ./programs/alacritty.nix
    # ./programs/neovim.nix
  ];

  home = {
    username = "nick";
    homeDirectory = "/home/nick";
    stateVersion = "23.11"; # Anpassen an Ihre NixOS Version (z.B. "24.05")

    # Umgebungsvariablen für den Benutzer
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      # QT_STYLE_OVERRIDE = if isKDE then null else "kvantum"; # Beispiel für Kvantum außerhalb von KDE
      # GTK_THEME = "MyCustomGtkTheme"; # Wird besser in theming.nix gehandhabt
      FLAKE_TARGET = currentSystem; # Für Aliase in Shells
      FLAKE_HOSTNAME = hostname;    # Für Aliase in Shells
    };

    # Standard XDG Benutzerverzeichnisse (optional, werden oft automatisch erstellt)
    file.".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/Desktop"
      XDG_DOCUMENTS_DIR="$HOME/Dokumente"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_MUSIC_DIR="$HOME/Musik"
      XDG_PICTURES_DIR="$HOME/Bilder"
      XDG_PUBLICSHARE_DIR="$HOME/Öffentlich"
      XDG_TEMPLATES_DIR="$HOME/Vorlagen"
      XDG_VIDEOS_DIR="$HOME/Videos"
    '';
    # Erstellt die Verzeichnisse, falls sie nicht existieren
    activation = {
      createXdgUserDirs = ''
        ${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update
      '';
    };
  };

  # XDG Mime-Anwendungen (Standardanwendungen)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/mailto" = [ "evolution.desktop" ]; # Oder thunderbird.desktop etc.
      "image/jpeg" = [ "org.kde.gwenview.desktop" "org.gnome.Loupe.desktop" ]; # Fallback
      "image/png" = [ "org.kde.gwenview.desktop" "org.gnome.Loupe.desktop" ];
      "application/pdf" = [ "org.kde.okular.desktop" "org.gnome.Evince.desktop" ];
    };
    # Assoziationen für bestimmte Dateitypen
    # associations.added = {
    #   "text/plain" = [ "neovim.desktop" "codium.desktop" ];
    # };
  };

  # XDG Portale (wichtig für Flatpak, Snap, Screensharing etc.)
  xdg.portal = {
    enable = true; # Stellt sicher, dass xdg-desktop-portal läuft
    # Die extraPortals werden oft vom System-Desktop-Modul bereitgestellt.
    # Hier können sie ergänzt oder überschrieben werden.
    # extraPortals = with pkgs;
    #   lib.optionals isKDE [ xdg-desktop-portal-kde ] ++
    #   lib.optionals isGNOME [ xdg-desktop-portal-gnome ] ++ # GNOME bringt seinen eigenen Portal mit
    #   lib.optionals isHyprland [ xdg-desktop-portal-hyprland xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    # gtkUsePortal = true; # Erzwingt die Nutzung von Portalen für GTK-Dateidialoge
  };

  # Git Konfiguration
  programs.git = {
    enable = true;
    userName = "Nick";
    userEmail = "nick@example.com"; # Anpassen!
    signing = {
      key = null; # Hier GPG Key ID eintragen, falls Commits signiert werden sollen
      signByDefault = false;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      # Weitere Git-Einstellungen
      "credential.helper" = if pkgs.stdenv.isLinux then "${pkgs.libsecret}/bin/git-credential-libsecret" else null;
    };
    # LFS Unterstützung
    lfs.enable = true;
  };

  # Starship Prompt (für Zsh und Fish)
  programs.starship = {
    enable = true;
    enableZshIntegration = true; # Wird in shells.nix genauer gehandhabt
    enableFishIntegration = true; # Wird in shells.nix genauer gehandhabt
    # Konfiguration kann hier oder in ~/.config/starship.toml erfolgen
    # settings = {
    #   add_newline = false;
    #   character = { symbol = "➜"; style_success = "bold green"; style_failure = "bold red"; };
    # };
  };

  # Direnv für projekt-spezifische Umgebungsvariablen
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Integration mit Nix-Shells
  };

  # Grundlegende dconf Einstellungen (hauptsächlich für GNOME/GTK Apps)
  dconf.settings = {
    # Beispiel:
    # "org/gnome/desktop/interface" = {
    #   gtk-theme = "Adwaita-dark";
    #   icon-theme = "Papirus-Dark";
    # };
  };

  # Services, die vom Benutzer verwaltet werden
  systemd.user.services = {
    # Beispiel: Ein benutzerdefinierter Service
    # my-custom-user-service = {
    #   Unit = {
    #     Description = "My custom user service";
    #     After = [ "graphical-session-pre.target" ];
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.writeShellScript "my-script" ''echo "Hello from user service"''}";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
