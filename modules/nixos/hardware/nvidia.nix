# nixos-config/modules/nixos/hardware/nvidia.nix
{ config, pkgs, lib, ... }:

let
  # Wähle den NVIDIA Treiber. 'stable' ist meist eine gute Wahl.
  # Optionen: 'latest', 'beta', 'production', 'open'.
  # Für ältere Karten ggf. 'legacy_XYZ' (z.B. legacy_470). Siehe NixOS Wiki.
  nvidiaDriverPackage = pkgs.linuxPackages.nvidia_x11_stable; # Oder eine andere Version
in
{
  # NVIDIA Treiber
  services.xserver.videoDrivers = [ "nvidia" ];

  # Lädt die notwendigen NVIDIA Kernelmodule
  # Für Wayland sind "nvidia", "nvidia_modeset", "nvidia_uvm", "nvidia_drm" wichtig.
  # NixOS' `hardware.nvidia.modesetting.enable = true` sollte dies korrekt handhaben.
  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.extraModulePackages = [ nvidiaDriverPackage.kernel ]; # Stellt sicher, dass die Kernelmodule zum Treiber passen

  hardware.nvidia = {
    # Automatische Installation der NVIDIA Treiber
    modesetting.enable = true; # Sehr wichtig für Wayland und moderne Xorg Versionen!
    powerManagement.enable = false; # Standard ist false. Kann bei Problemen auf true gesetzt werden.
    powerManagement.finegrained = false; # dito
    open = false; # Proprietäre Treiber verwenden. `true` für den Open-Source-Kernelmodul-Versuch (noch nicht für alle Karten/Features reif).
    nvidiaSettings = true; # Installiert das `nvidia-settings` GUI-Tool.
    package = nvidiaDriverPackage;

    # Prime Render Offload (für Laptops mit Intel iGPU + NVIDIA dGPU)
    # prime = {
    #   sync.enable = true; # Empfohlen für bessere Performance und weniger Tearing
    #   # Die Bus IDs müssen korrekt für Ihr System ermittelt werden via `lspci | grep -E "VGA|3D"`
    #   # intelBusId = "PCI:X:Y:Z"; # z.B. "PCI:0:2:0"
    #   # nvidiaBusId = "PCI:A:B:C"; # z.B. "PCI:1:0:0"
    # };
  };

  # OpenGL Unterstützung (wird auch in common.nix gesetzt, hier zur Sicherheit für NVIDIA)
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true; # Für 32-Bit Spiele/Anwendungen (Steam, Wine)

  # Umgebungsvariablen für Wayland mit NVIDIA (kann helfen, ist aber oft nicht mehr nötig mit modernen Treibern/Compositors)
  # environment.sessionVariables = lib.mkIf config.hardware.nvidia.modesetting.enable {
  #   GBM_BACKEND = "nvidia-drm";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   # WLR_NO_HARDWARE_CURSORS = "1"; # Für einige Wayland-Compositoren, falls Cursor-Probleme auftreten
  # };

  # Für CUDA-Entwicklung (optional)
  # hardware.nvidia.cudaSupport = true;
  # hardware.nvidia.cudaPackages.cudatoolkit = pkgs.cudatoolkit; # Wählt das CUDA Toolkit
}
