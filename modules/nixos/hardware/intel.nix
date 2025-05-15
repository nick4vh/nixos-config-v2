# nixos-config/modules/nixos/hardware/intel.nix
{ config, pkgs, lib, ... }:

{
  # Intel GPU Treiber (Mesa)
  # 'modesetting' ist der generische KMS-Treiber und wird meist bevorzugt.
  # 'intel' ist der ältere Treiber und für manche (sehr alte) Hardware noch relevant.
  services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver # Für VA-API Hardware-Video-Beschleunigung auf neueren Intel GPUs (Broadwell+)
    # libva-intel-driver # Für ältere Intel GPUs (vor Broadwell)
    libva-utils # Zum Testen von VA-API (vainfo)
    intel-gpu-tools # Für Debugging und Profiling von Intel GPUs
  ];

  # Firmware für Intel WiFi/Bluetooth (oft schon im linux-firmware Paket enthalten)
  hardware.enableRedistributableFirmware = true; # Stellt sicher, dass auch unfreie Firmware geladen wird, falls nötig
}
