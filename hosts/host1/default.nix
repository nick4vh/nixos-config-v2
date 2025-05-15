# nixos-config/hosts/host1/default.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Importiert die bei der Installation generierte hardware-configuration.nix
    # Diese Datei MUSS vom Benutzer in dieses Verzeichnis (`hosts/host1/`) kopiert werden.
    ./hardware-configuration.nix

    # Host-spezifische Module (Intel + NVIDIA)
    ./../../modules/nixos/hardware/intel.nix
    ./../../modules/nixos/hardware/nvidia.nix
  ];

  networking.hostName = "host1"; # Eindeutiger Hostname

  # Bootloader-Konfiguration (kann in hardware-configuration.nix definiert sein oder hier überschrieben werden)
  # Die folgenden Einstellungen sind Beispiele und sollten an die hardware-configuration.nix angepasst werden.
  boot.loader.grub = {
    enable = true;
    # device = "/dev/sda"; # Wird oft in hardware-configuration.nix gesetzt. Falls nicht, hier eintragen.
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true; # Oft in hardware-configuration.nix

  # Dateisysteme und Swap werden typischerweise in hardware-configuration.nix definiert.
  # fileSystems."/" = { ... };
  # fileSystems."/boot" = { ... };
  # swapDevices = [ ... ];

  # Kernel-Auswahl (optional, Standard ist meist gut)
  # boot.kernelPackages = pkgs.linuxPackages_zen;

  # NVIDIA spezifische Einstellungen werden in modules/nixos/hardware/nvidia.nix gehandhabt.
  # Intel spezifische Einstellungen werden in modules/nixos/hardware/intel.nix gehandhabt.
}
