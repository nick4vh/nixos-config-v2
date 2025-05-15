# nixos-config/modules/nixos/services/firewall.nix
{ config, pkgs, ... }:

{
  # NixOS verwendet standardmäßig nftables. `networking.firewall.enable = true`
  # aktiviert eine einfache zustandsbehaftete Firewall, die ausgehenden Traffic erlaubt
  # und eingehenden Traffic blockiert, außer für explizit erlaubte Ports/Dienste.

  networking.firewall.enable = true;

  # Alternativ kann firewalld für eine zonenbasierte Verwaltung verwendet werden:
  # services.firewalld.enable = true;
  # networking.firewall.enable = false; # Muss deaktiviert werden, wenn firewalld genutzt wird.

  # Beispiele für das Öffnen von Ports (wenn networking.firewall.enable = true):
  # networking.firewall.allowedTCPPorts = [ 22 ]; # SSH (wird von services.openssh automatisch gehandhabt, wenn enable = true)
  # networking.firewall.allowedUDPPorts = [ ];

  # Für KDE Connect (Ports 1714-1764 TCP/UDP)
  # Diese werden oft automatisch von `programs.kdeconnect.enable = true` gehandhabt,
  # wenn die Firewall-Integration des Moduls greift.
  # Ansonsten manuell:
  # networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  # networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  # Wenn firewalld verwendet wird:
  # services.firewalld.trustedInterfaces = [ "docker0" "virbr0" ]; # Beispiel für Docker und libvirt
  # services.firewalld.defaultZone = "public"; # Oder "home", "work"
}
