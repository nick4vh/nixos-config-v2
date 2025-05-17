# nixos-config/modules/nixos/gaming.nix
{ config, pkgs, lib, ... }:

{
  # Vulkan Unterstützung (bereits in common.nix und hardware Modulen, hier zur Verdeutlichung)
  hardware.opengl.enable = true;

  # Pakete für Gaming (einige sind besser als User-Pakete, aber hier als Systemoption für Bibliotheken)
  environment.systemPackages = with pkgs; [
    vulkan-tools # Für `vulkaninfo` und Tests
    vulkan-loader
    # mesa.drivers # Mesa-Treiber (werden durch hardware.opengl.enable bereitgestellt)
    # Für NVIDIA: nvidia-vaapi-driver für VA-API über NVIDIA (experimentell)
    # libva # VA-API Implementierung

    # Wine und verwandte Pakete (oft besser per Home Manager für den Benutzer `nick`)
    # wineWowPackages.stable # Enthält 64-bit und 32-bit Wine
    # winetricks
    # dxvk # DX9/10/11 auf Vulkan
    # vkd3d-proton # DX12 auf Vulkan

    # Gamescope für Wayland/X11 Compositing und Upscaling von Spielen
    gamescope

    # MangoHud für Leistungsüberwachung in Spielen
    mangohud
  ];

  # Kernel-Optimierungen (optional, Standard-Kernel ist oft gut genug)
  # boot.kernelPackages = pkgs.linuxPackages_zen; # Zen-Kernel
  # boot.kernelPackages = pkgs.linuxPackages_xanmod; # XanMod-Kernel
  # Wenn ein spezieller Kernel verwendet wird, sicherstellen, dass externe Module (NVIDIA) kompatibel sind.
  # NixOS handhabt dies meist gut.

  # Controller Support
  # Grundlegende Joystick-Unterstützung ist normalerweise im Kernel enthalten.
  # Spezifische Controller-Unterstützung kann über udev-Regeln oder Pakete hinzugefügt werden.
  services.udev.packages = with pkgs; [
    # Pakete für spezifische Controller-Unterstützung, falls nötig:
    # z.B. `xone-dkms` (für moderne Xbox Controller, erfordert Kernel-Header)
    # `ds4drv` (für DualShock 4, oft nicht mehr nötig, da Kernel-Support gut ist)
    # Steam selbst bringt oft schon gute Controller-Unterstützung mit (Steam Input).
  ];

  # FUSE für Proton/Steam (AppImage, etc.)
  # Wird oft automatisch durch `programs.steam.enable = true` im Home Manager oder systemweit gehandhabt.
  # Falls nicht:
  # users.users.nick.extraGroups = [ "fuse" ]; # Erlaubt das Mounten von FUSE Dateisystemen
  # Oder systemweit:
  # environment.systemPackages = [ pkgs.fuse ];

  # Gamemode für Performance-Optimierungen beim Spielen
  programs.gamemode.enable = true;

  # MangoHud systemweit aktivieren (optional, kann auch pro Spiel via Steam gestartet werden)
  # programs.mangohud.enable = true; # Wird bereits in environment.systemPackages hinzugefügt
  # programs.mangohud.enableSessionWide = true; # Lädt MangoHud für alle Anwendungen (zum Testen)

  # PipeWire für Audio (bereits in audio.nix konfiguriert)
  # services.pipewire.enable = true;
  # services.pipewire.alsa.support32Bit = true; # Wichtig für 32-Bit Spiele

  # Spezielle Einstellungen für Steam
  programs.steam = {
    enable = true; # Systemweite Installation von Steam (oft besser per Home Manager)
  };
}
