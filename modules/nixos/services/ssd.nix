# nixos-config/modules/nixos/services/ssd.nix
{ config, pkgs, ... }:

{
  # Kontinuierliches TRIM wird bereits durch die `discard` Option in `fileSystems` (common.nix)
  # für die jeweiligen Mountpoints aktiviert.
  # Periodisches TRIM über einen systemd Timer kann zusätzlich oder alternativ verwendet werden.
  services.fstrim.enable = true; # Aktiviert wöchentliches TRIM per systemd Timer
}
