# nixos-config/modules/nixos/services/audio.nix
{ config, pkgs, ... }:

{
  sound.enable = true; # Grundlegende ALSA-Unterstützung
  hardware.pulseaudio.enable = false; # Deaktivieren, da wir Pipewire verwenden

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # Für 32-Bit Anwendungen (Steam, Wine)
    pulse.enable = true;      # PipeWire als PulseAudio Ersatz
    jack.enable = true;       # PipeWire als JACK Ersatz (optional aber empfohlen)
    wireplumber.enable = true; # Session Manager für Pipewire (Standard und empfohlen)
    # Optional: RTKit für Echtzeit-Prioritäten (kann Latenz verbessern)
    # rtkit.enable = true;
  };

  # Sicherstellen, dass der Benutzer der 'audio' und 'video' Gruppe angehört
  # (wird bereits in common.nix für 'nick' gemacht, hier als allgemeine Anmerkung)
  # users.users.nick.extraGroups = [ "audio" "video" ];

  # Pakete für PipeWire-Verwaltung (optional, oft in DEs integriert)
  # environment.systemPackages = with pkgs; [
  #   qpwgraph # Graphischer Patchbay für PipeWire (ähnlich Catia für JACK)
  #   helvum   # Einfacherer Patchbay
  # ];
}
