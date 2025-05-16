# nixos-config/modules/home-manager/nick/packages.nix
{ pkgs, config, lib, ... }:

{
  home.packages = with pkgs; [
    # Development
    vscodium            # VS Code ohne Microsoft Telemetrie
    # (vscode-with-extensions.override { # VSCodium mit Extensions
    #   vscodeExtensions = with vscode-extensions; [
    #     # Hier Extensions eintragen, z.B. vscodevim.vim
    #   ];
    # })
    neovim              # Neovim Texteditor
    vim                 # Klassischer Vim
    nodejs_20           # Node.js (Version 20, oder _latest, _18 etc.)
    yarn                # Paketmanager für Node.js
    # git               # Wird über programs.git konfiguriert
    # wget              # Bereits in systemPackages
    docker-client       # Docker CLI (Daemon kommt vom System)
    docker-compose      # Für Multi-Container Docker Applikationen
    # (postman.override { mengatasiCA = true; }) # Postman API Client (mit Workaround für CA-Probleme)
    # Oder: insomnia # Alternative zu Postman

    # Design
    inkscape            # Vektorgrafikeditor
    gimp                # Bildbearbeitungsprogramm
    krita               # Digitales Malprogramm
    (if pkgs.stdenv.isLinux && config.home.sessionVariables.FLAKE_TARGET != null && lib.strings.hasSuffix "-kde" config.home.sessionVariables.FLAKE_TARGET 
     then kdePackages.kdenlive 
     else kdenlive)     # Videoschnitt (KDE-Version, wenn KDE aktiv)

    # Browser
    firefox             # Firefox Browser
    # firefox-wayland   # Alias, der sicherstellt, dass Wayland verwendet wird
    chromium            # Chromium Browser
    brave               # Brave Browser

    # Gaming
    # vulkan-tools      # Bereits in systemPackages (gaming.nix)
    steam               # Steam Gaming Plattform
    steam-run           # Zum Ausführen von nicht-Steam Spielen in Steam Runtime
    protonup-qt         # Zum Verwalten von Proton-Versionen für Steam
    lutris              # Gaming Plattform für Linux
    wineWowPackages.stable # Enthält 64-bit und 32-bit Wine
    winetricks          # Hilfsskript für Wine
    retroarchFull       # Frontend für Emulatoren
    pcsx2               # Emulator für PlayStation 2 (QT Version)
    discord             # Voice- und Text-Chat für Gamer

    # Tools
    obs-studio          # Software für Videoaufnahme und Live-Streaming
    bitwarden-desktop   # Passwort-Manager (Desktop App)
    # bitwarden-cli     # CLI für Bitwarden
    joplin-desktop      # Notiz- und To-Do-Anwendung mit Synchronisation
    libreoffice-fresh   # LibreOffice (neueste Version, GTK)
    # libreoffice-qt    # LibreOffice mit Qt-Integration (für KDE)
    nextcloud-client    # Nextcloud Desktop Client
    evolution           # Persönlicher Informationsmanager (Mail, Kalender, Kontakte) für GNOME
    # zsh               # Wird in shells.nix verwaltet
    # fish              # Wird in shells.nix verwaltet
    vlc                 # Vielseitiger Mediaplayer
    spotify             # Musik-Streaming-Dienst (Flatpak oft stabiler, falls Probleme)
    (if pkgs.stdenv.isLinux && config.home.sessionVariables.FLAKE_TARGET != null && lib.strings.hasSuffix "-kde" config.home.sessionVariables.FLAKE_TARGET 
     then kdePackages.kdeconnect-kde 
     else gnome.gsconnect) # Smartphone-Integration (KDE Connect oder GSConnect für GNOME)
    mpv                 # Leistungsstarker Kommandozeilen-Mediaplayer
    alacritty           # Schneller, GPU-beschleunigter Terminal-Emulator
    # htop, btop, neofetch, fastfetch # Bereits in systemPackages
    clamtk              # GUI für ClamAV (wenn ClamAV systemweit installiert ist)

    # ChatAI
    # qt6.qtwebengine   # Qt WebEngine, oft eine Abhängigkeit für Chat-Apps
    # Für spezifische Apps:
    # z.B. `chatgpt-desktop` (falls als Paket verfügbar) oder über Flatpak/Web

    # KVM (Client tools, Server-Teil ist systemweit)
    # virt-manager, virt-viewer # Bereits in systemPackages

    # KDE Theme spezifische Pakete (werden in theming.nix oder Desktop-Modulen gehandhabt)
    # Schriftarten (werden in theming.nix verwaltet)
    # Icon-Theme (wird in theming.nix verwaltet)

    # Nützliche CLI Tools
    ripgrep             # Schneller als grep
    fd                  # Einfacher als find
    fzf                 # Fuzzy Finder für die Kommandozeile
    bat                 # Cat-Klon mit Syntax-Highlighting und Git-Integration
    eza                 # Nachfolger von exa
    tldr                # Vereinfachte Manpages
    jq                  # JSON Prozessor
    yq-go               # YAML, JSON, XML Prozessor
    tree                # Verzeichnisbäume anzeigen
    ncdu                # Festplattenbelegung analysieren
    silver-searcher  # Code-Suchtool (ähnlich ack, grep)

    # Für Shells.nix (Plugin Manager etc.)
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    # fisher # Für Fish Shell, falls nicht über fish.plugins verwaltet
  ];

  # Einige Pakete könnten besser über Flatpak installiert werden,
  # falls sie Probleme machen oder sehr aktuelle Versionen benötigt werden.
  # z.B. Spotify, Discord
}
