# nixos-config/modules/nixos/common.nix
{ config, pkgs, lib, ... }:

{
  # Zeitzone und Locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  # Konsolen-Keymap
  console.keyMap = "de-latin1";

  # Grundlegende Pakete, die auf jedem System verfügbar sein sollen
  environment.systemPackages = with pkgs; [
    wget
    git
    htop
    btop
    neofetch
    fastfetch
    curl
    unzip
    p7zip
    gnupg # Für Verschlüsselung und Signierung
  ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  # Benutzer `nick`
  users.users.nick = {
    isNormalUser = true;
    description = "Nick";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "adbusers" "audio" "video" ];
    shell = pkgs.zsh; # Standard-Shell, kann von Home Manager überschrieben werden
    # Passwort muss manuell nach dem ersten Build gesetzt werden: `sudo passwd nick`
  };
  # Erlaube Benutzern in der Gruppe 'wheel', alle Befehle auszuführen
  security.sudo.wheelNeedsPassword = true; # oder false, wenn kein Passwort für sudo benötigt wird

  # Nix Konfiguration
  nix = {
    # Korrigierte Option für das Nix-Paket:
    package = pkgs.nixVersions.stable; # Ersetzt pkgs.nixFlakes
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Optional: Zusätzliche Binary Caches für schnellere Paketinstallationen
    # binaryCaches = [ "https://cache.nixos.org/" "https://nix-community.cachix.org" ];
    # binaryCachePublicKeys = [
    #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];
  };

  # SSH Server (optional, aber oft nützlich)
  services.openssh = {
    enable = true;
    # settings.PasswordAuthentication = false; # Empfohlen: Nur Key-basierte Authentifizierung
    # settings.PermitRootLogin = "no";
  };

  # Bevorzuge Wayland, erlaube X11 Fallback
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Für Electron Apps auf Wayland (Chromium-basiert)
    MOZ_ENABLE_WAYLAND = "1"; # Für Firefox auf Wayland
  };

  # Grundlegende X11 und Wayland Unterstützung
  services.xserver.enable = true; # Auch für Wayland oft benötigt (XWayland)

  # Programme können 32-Bit Bibliotheken benötigen (z.B. Steam)
  hardware.opengl.enable = true;

  # Secure Boot (optional, erfordert manuelle Einrichtung der Schlüssel)
  # boot.loader.secureBoot.enable = false; # Standardmäßig aus, da es Setup erfordert
  # Wenn systemd-boot verwendet würde:
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot"; # Sicherstellen, dass der Mountpunkt korrekt ist
  # Für GRUB mit Secure Boot:
  # boot.loader.grub.secureBoot = "auto";
  # Dies erfordert signierte Kernel und Bootloader. NixOS kann dies mit `lanzaboote` oder manueller Signierung unterstützen.
  # Für den Anfang würde ich Secure Boot deaktiviert lassen.

  # NetworkManager wird für die meisten Desktop-Umgebungen empfohlen
  networking.networkmanager.enable = true;
  # Deaktiviere dhcpcd, da NetworkManager dies übernimmt
  networking.dhcpcd.enable = false;


  system.stateVersion = "23.11"; # Oder die Version, mit der Sie starten (z.B. "24.05")
}
