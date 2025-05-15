# nixos-config/modules/nixos/services/virtualization.nix
{ config, pkgs, ... }:

{
  # KVM und QEMU für virtuelle Maschinen
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;  # Für vTPM Unterstützung (z.B. für Windows 11 VMs)
        ovmf.enable = true;   # Für UEFI-Firmware in VMs
        ovmf.packages = [ pkgs.OVMFFull.fd ]; # Stellt sicher, dass Secure Boot fähige OVMF Firmware vorhanden ist
      };
    };

    # Docker
    docker = {
      enable = true;
      # Optional: Rootless Docker (erfordert zusätzliche Konfiguration pro Benutzer)
      # rootless = {
      #   enable = true;
      #   setSocketVariable = true;
      # };
    };
  };

  # Notwendige Pakete für VM Management (einige sind auch als User-Pakete sinnvoll)
  # Diese werden systemweit verfügbar gemacht.
  environment.systemPackages = with pkgs; [
    virt-manager     # GUI zur Verwaltung von VMs
    virt-viewer      # Anzeige-Tool für VMs
    # qemu             # Wird von libvirtd als Abhängigkeit gezogen, aber schadet nicht explizit
    # libvirt          # Wird durch virtualisation.libvirtd.enable bereitgestellt
    # dnsmasq          # Für virtuelle Netzwerke (oft von libvirtd automatisch verwaltet)
    bridge-utils     # Für Netzwerk-Bridge Support
    spice-gtk        # Für SPICE Support (verbesserte Grafikausgabe in VMs)
    win-virtio       # Treiber für Windows-VMs
    win-spice        # SPICE Guest Tools für Windows
  ];

  # Benutzer 'nick' zu den relevanten Gruppen hinzufügen (teilweise schon in common.nix)
  users.users.nick.extraGroups = lib.mkIf config.users.users.nick.isNormalUser [
    "libvirtd" # Für die Verwaltung von VMs mit virt-manager
    "docker"   # Für die Verwendung von Docker
  ];

  # Netzwerk für libvirt (Standard NAT Netzwerk "default" wird oft automatisch erstellt)
  # Kernelmodule für Virtualisierung und Netzwerk-Bridging
  boot.kernelModules = [ "kvm-intel" "kvm-amd" "tun" "tap" "vhost_net" ]; # kvm-amd nur wenn AMD CPU
  # Für Intel CPUs ist kvm-intel, für AMD CPUs kvm-amd. NixOS lädt meist das passende.
  # boot.extraModprobeConfig = "options kvm_intel nested=1"; # Nested Virtualization für Intel (optional)
}
