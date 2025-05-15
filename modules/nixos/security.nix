# nixos-config/modules/nixos/security.nix
{ config, pkgs, lib, ... }:

{
  # AppArmor (mandatory access control)
  security.apparmor.enable = true;

  # Systemd Service Sandboxing
  # Viele Services in nixpkgs sind bereits mit Sandboxing-Optionen konfiguriert.
  # Dies ist eine Stärke von NixOS. Man kann dies pro Service weiter verfeinern.
  # z.B. systemd.services.<name>.serviceConfig = { PrivateTmp = true; ProtectSystem = "strict"; ... };

  # Deaktivieren unnötiger Dienste
  # Dies geschieht implizit in NixOS, da nur explizit aktivierte Dienste laufen.
  # Man könnte hier explizit Dienste deaktivieren, falls sie von anderen Modulen
  # standardmäßig aktiviert werden und man sie nicht möchte.
  # services.exampleService.enable = lib.mkForce false;

  # ClamAV Antivirenschutz (als User-Paket oder systemweit)
  # services.clamav = {
  #   daemon.enable = true;
  #   updater.enable = true; # Automatisches Update der Virendefinitionen
  # };
  # `clamtk` (GUI) oder `clamscan` (CLI) können dann über User-Pakete installiert werden.

  # Kernel-Optimierungen für Sicherheit (Beispiele, mit Vorsicht anwenden)
  # boot.kernel.sysctl = {
  #   "kernel.yama.ptrace_scope" = 1; # Beschränkt ptrace auf Kindprozesse
  #   "net.ipv4.conf.default.rp_filter" = 1; # Reverse Path Filtering
  #   "net.ipv4.conf.all.rp_filter" = 1;
  #   "net.ipv4.tcp_syncookies" = 1; # Schutz gegen SYN-Flood-Attacken
  #   "vm.mmap_rnd_bits" = 32; # Erhöht ASLR für mmap
  #   "vm.mmap_rnd_compat_bits" = 16;
  # };

  # Optimierungen für Startzeit und Speichernutzung
  # Zstd Kompression für initrd (kann Bootzeit leicht verbessern)
  # Korrigierte Option:
  boot.initrd.compressor = "zstd";
  # Optional: Argumente für den Kompressor, z.B. Kompressionslevel
  # boot.initrd.compressorArgs = [ "-10" ]; # Beispiel für zstd Kompressionslevel 10

  # Firejail für Anwendungs-Sandboxing (optional, kann per Home Manager oder systemweit)
  # programs.firejail.enable = true;
  # programs.firejail.wrappedBinaries = {
  #   firefox = {
  #     executable = "${lib.getBin pkgs.firefox}/bin/firefox";
  #     profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
  #   };
  #   # Weitere Anwendungen...
  # };

  # Automatische Sicherheitsupdates (optional)
  # system.autoUpgrade = {
  #   enable = true;
  #   flake = "/root/nixos-config"; # Pfad zu dieser Flake-Konfiguration
  #   dates = "03:00"; # Zeitpunkt für tägliche Updates
  #   flags = [ "--update-input" "nixpkgs" ]; # Aktualisiert auch den nixpkgs Input
  #   # channel = "nixos-unstable"; # Wenn kein Flake verwendet wird
  # };
  # Dies erfordert, dass die Konfiguration an einem Ort liegt, auf den root Zugriff hat.

  # Deaktivieren von Telemetrie in pkgs (wo unterstützt)
  environment.variables.NIXPKGS_ALLOW_UNFREE_REDISTRIBUTABLE_DEFAULTS = "1"; # Beispiel, nicht direkt Telemetrie
  # Es gibt keine globale Option, um alle Telemetrie zu deaktivieren, dies ist anwendungsspezifisch.
}
