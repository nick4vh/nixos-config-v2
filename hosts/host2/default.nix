# nixos-config/hosts/host2/default.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Importiert die bei der Installation generierte hardware-configuration.nix
    # Diese Datei MUSS vom Benutzer in dieses Verzeichnis (`hosts/host2/`) kopiert werden.
    ./hardware-configuration.nix

    # Host-spezifische Module (nur Intel)
    ./../../modules/nixos/hardware/intel.nix
    # Kein NVIDIA Modul für diesen Host
  ];

  networking.hostName = "host2"; # Eindeutiger Hostname

  # Bootloader-Konfiguration (siehe Hinweise in hosts/host1/default.nix)
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # Oft in hardware-configuration.nix
    efiSupport = false;
    efiInstallAsRemovable = false;
    timeout = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true; # Oft in hardware-configuration.nix

  # Dateisysteme und Swap werden typischerweise in hardware-configuration.nix definiert.

  # Intel spezifische Einstellungen werden in modules/nixos/hardware/intel.nix gehandhabt.
}
