# nixos-config/modules/nixos/services/bluetooth.nix
{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Bluetooth beim Start aktivieren
    # Optional: experimentalFeatures für neuere Bluetooth-Funktionen
    # experimentalFeatures = true;
  };

  # Blueman ist ein GTK-basierter Bluetooth-Manager, gut für XFCE, LXQt, Hyprland etc.
  # GNOME und KDE haben eigene Integrationen.
  # services.blueman.enable = true;

  # Für KDE Plasma wird bluez-qt automatisch mitinstalliert und integriert.
  # Für GNOME ist die Integration ebenfalls vorhanden.
  # Dieses Modul stellt die Basis-Bluetooth-Funktionalität bereit.
  # Die Desktop-Module können spezifische GUI-Tools hinzufügen.
}
