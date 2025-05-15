# nixos-config/hosts/host2.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Importiert die bei der Installation generierte hardware-configuration.nix
    # oder definieren Sie die Hardware hier direkt.
    # ./hardware-configuration.nix
    ./../modules/nixos/hardware/intel.nix
    # Kein NVIDIA Modul für diesen Host
  ];

  networking.hostName = "host2"; # Eindeutiger Hostname

  # Bootloader-Konfiguration
  boot.loader.systemd-boot.enable = lib.mkForce false; # Deaktivieren, falls es von hardware-configuration.nix kommt
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # GRUB auf dem Laufwerk installieren
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Dateisysteme
  # Ersetzen Sie dies mit den Inhalten Ihrer generierten hardware-configuration.nix
  # oder passen Sie es an Ihre Partitionierung an.
  fileSystems."/" = {
    device = "/dev/sda1"; # Ihre Root-Partition
    fsType = "ext4";
    options = [ "defaults" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/sda2"; # Ihre EFI System Partition (ESP)
    fsType = "vfat";
  };

  # Swap (Beispiel)
  # swapDevices = [ { device = "/dev/sda3"; } ];

  # Intel spezifische Einstellungen werden in modules/nixos/hardware/intel.nix gehandhabt.
}
