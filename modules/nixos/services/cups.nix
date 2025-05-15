# nixos-config/modules/nixos/services/cups.nix
{ config, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint gutenprintBin # Umfangreiche Sammlung von Open-Source-Treibern
      foomatic-db foomatic-db-engine foomatic-db-nonfree # Foomatic-Datenbanken
      # Spezifische Treiberpakete nach Bedarf:
      hplipWithPlugin # Für HP Drucker und Scanner (mit proprietärem Plugin)
      # brlaser # Für einige Brother Laserdrucker
      # epson-escpr # Für Epson Tintenstrahldrucker
    ];
    # Erlaube Netzwerkdrucker-Browsing
    browsing = true;
    defaultShared = true; # Drucker standardmäßig im Netzwerk freigeben (optional)
  };

  # Benutzer zur 'lpadmin' Gruppe hinzufügen, um Drucker verwalten zu können
  # (wird bereits in common.nix für 'nick' gemacht, hier als allgemeine Anmerkung)
  # users.users.nick.extraGroups = [ "lpadmin" ];

  # Firewall-Regeln für CUPS (falls eine restriktive Firewall konfiguriert ist)
  # networking.firewall.allowedTCPPorts = [ 631 ]; # IPP (Internet Printing Protocol)
  # networking.firewall.allowedUDPPorts = [ 631 ];
}
