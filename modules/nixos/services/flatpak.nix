# nixos-config/modules/nixos/services/flatpak.nix
{ config, pkgs, ... }:

{
  services.flatpak.enable = true;

  # XDG Portale sind wichtig für die Integration von Flatpaks (Dateizugriff, etc.)
  # Diese werden oft auch von den Desktop-Modulen (KDE, GNOME) konfiguriert.
  xdg.portal = {
    enable = true;
    # Stellt sicher, dass die Portale für die installierten Desktops vorhanden sind.
    # Die spezifischen Portale werden in den Desktop-Modulen hinzugefügt.
    # extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # Fallback
  };
}
