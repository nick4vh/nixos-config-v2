# nixos-config/hosts/host1.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Importiert die bei der Installation generierte hardware-configuration.nix
    # oder definieren Sie die Hardware hier direkt.
    # ./hardware-configuration.nix 
    ./../modules/nixos/hardware/intel.nix
    ./../modules/nixos/hardware/nvidia.nix
  ];

  networking.hostName = "host1"; # Eindeutiger Hostname

  # Bootloader-Konfiguration
  boot.loader.systemd-boot.enable = lib.mkForce false; # Deaktivieren, falls es von hardware-configuration.nix kommt
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # GRUB auf dem Laufwerk installieren, nicht auf der Partition
    efiSupport = true;
    efiInstallAsRemovable = true; # Macht es portabler und vermeidet Probleme mit BIOS-Updates
    # useOSProber = true; # Falls andere OS erkannt werden sollen
  };
  boot.loader.efi.canTouchEfiVariables = true;


  # Dateisysteme
  # Ersetzen Sie dies mit den Inhalten Ihrer generierten hardware-configuration.nix
  # oder passen Sie es an Ihre Partitionierung an.
  fileSystems."/" = {
    device = "/dev/sda1"; # Ihre Root-Partition
    fsType = "ext4";      # Oder btrfs, xfs, etc.
    options = [ "defaults" "discard" ]; # "discard" für SSD TRIM
  };

  fileSystems."/boot" = {
    device = "/dev/sda2"; # Ihre EFI System Partition (ESP)
    fsType = "vfat";
  };

  # Swap (Beispiel, falls eine Swap-Partition existiert)
  # swapDevices = [ { device = "/dev/sda3"; } ];

  # Kernel-Auswahl (optional, Standard ist meist gut)
  # boot.kernelPackages = pkgs.linuxPackages_zen; # Für Zen-Kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # NVIDIA spezifische Einstellungen werden in modules/nixos/hardware/nvidia.nix gehandhabt.
}
