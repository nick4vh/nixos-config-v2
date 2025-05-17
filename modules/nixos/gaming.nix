# nixos-config/modules/nixos/gaming.nix
{ config, pkgs, lib, ... }:

{
  imports = [];
  
  nixpkgs.config = {
    allowUnfree = true;
    # Wichtig für Steam und manche Spiele
    packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          libgdiplus
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          at-spi2-atk
          at-spi2-core
          gtk3
          glib
          pango
          gdk-pixbuf
          cairo
          atk
          zlib
          glibc
          openssl
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Gaming-Plattformen
    steam
    lutris
    heroic
    bottles
    mangohud
    goverlay
    gamemode
    
    # Tools für Windows-Kompatibilität / Proton
    wineWowPackages.staging
    winetricks
    protonup-qt
    
    # Controller-Support
    antimicrox
    
    # Tools und Abhängigkeiten für bessere Kompatibilität
    protontricks
    steam-run
    glxinfo
    pciutils
    
    # Bibliotheken, die für viele Spiele benötigt werden
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL
    libva
    
    # Audio-Bibliotheken
    alsa-lib
    alsa-plugins
    libpulseaudio
    
    # Für Counter-Strike: Source spezifisch hilfreich
    gnutls
    openal
    libvdpau
    
  ] ++ (with pkgs.pkgsi686Linux; [
    libpulseaudio
    libGL
    vulkan-loader
    libvdpau
    alsa-lib
    alsa-plugins
    libpng
    libgpg-error
    gnutls
    openal
  ]);

  # Gamemode aktivieren für bessere Spielleistung
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode aktiviert'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode deaktiviert'";
      };
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;  # Optionaler Gamescope-Support für bessere Performance
  };

  # Vulkan Support
  hardware.opengl = {
    enable = true;
    # driSupport = true;  # Diese Option ist jetzt standardmäßig aktiviert
    driSupport32Bit = true;  # Diese Option ist noch wichtig für 32-Bit-Spiele
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
      libva
      vaapiVdpau
    ];
  };

  # Ersetzen von hardware.graphics durch hardware.opengl
  # hardware.graphics ist veraltet
  
  hardware.steam-hardware.enable = true;
  
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;  # Für Audioanwendungen, die JACK verwenden
  };

  services.udev.packages = with pkgs; [ steam ];
  
  # Erweiterte Firewall-Regeln für Steam
  networking.firewall = {
    allowedTCPPorts = [ 27036 27037 ];
    allowedUDPPorts = [ 27031 27036 27037 ];
    # Zusätzliche In-Home-Streaming-Ports
    allowedTCPPortRanges = [ { from = 27015; to = 27050; } ];
    allowedUDPPortRanges = [ { from = 27000; to = 27100; } ];
  };

  services.flatpak.enable = true;
  
  # Environment-Variablen für Steam und Proton
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.steam/root/compatibilitytools.d";
    # Hilft bei Problemen mit OpenGL in einigen Spielen
    LIBGL_DRI3_DISABLE = "1";
    # Hilft bei manchen Source-Engine-Spielen
    __GL_THREADED_OPTIMIZATIONS = "1";
    # Verbesserung der Nvidia-Treiber-Performance (falls verwendet)
    __GL_SHADER_DISK_CACHE = "1";
    # Deaktiviert Async-Shader-Kompilation, die bei CS:S zu Abstürzen führen kann
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
  };

  # ACO Compiler für AMD-GPUs aktivieren (falls vorhanden)
  environment.variables = lib.mkIf (config.services.xserver.videoDrivers != null && 
                               builtins.elem "amdgpu" config.services.xserver.videoDrivers) {
    RADV_PERFTEST = "aco";
  };

  # Die folgenden Core-Limits verbessern die Stabilität von Spielen
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 98; }
    { domain = "@users"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@users"; item = "nofile"; type = "soft"; value = 8192; }
  ];

  # Für USB-Controller wichtig
  hardware.xpadneo.enable = true;
  hardware.xone.enable = true;
}
