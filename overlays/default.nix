# nixos-config/overlays/default.nix
# Diese Datei wird von flake.nix als Overlay eingebunden.
# Overlays erlauben es, bestehende Pakete zu modifizieren oder neue hinzuzufügen.

self: super: # self ist der finale Paketset, super ist der vorherige (ohne dieses Overlay)

{
  # Beispiel 1: Ein Paket mit einer anderen Version oder Konfiguration überschreiben
  # myCustomNeovim = super.neovim.overrideAttrs (oldAttrs: rec {
  #   version = "0.10.0"; # Fiktive neuere Version
  #   src = super.fetchFromGitHub {
  #     owner = "neovim";
  #     repo = "neovim";
  #     rev = "v${version}";
  #     sha256 = "sha256-muss-hier-rein"; # Korrekten SHA256-Hash eintragen!
  #   };
  #   # Zusätzliche Build-Optionen oder Patches könnten hier eingefügt werden
  # });

  # Beispiel 2: Ein neues, eigenes Paket hinzufügen
  # myPersonalScript = super.writeShellScriptBin "my-script" ''
  #   #!/usr/bin/env bash
  #   echo "Hallo von meinem persönlichen Skript!"
  #   echo "Argumente: $@"
  # '';

  # Beispiel 3: Ein Paket aus einem anderen Flake-Input verwenden (falls als Legacy-Paket benötigt)
  # someHyprlandPlugin = inputs.some-hyprland-plugin-flake.packages.${super.system}.default;

  # Beispiel 4: Catppuccin SDDM Theme (falls nicht direkt als Paket verfügbar oder Anpassung nötig)
  # catppuccin-sddm-mocha = super.stdenv.mkDerivation {
  #   pname = "catppuccin-sddm-theme-mocha";
  #   version = "git"; # oder eine spezifische Version
  #   src = inputs.catppuccin-sddm-theme; # Annahme: catppuccin-sddm-theme ist ein Flake-Input
  #                                       # src = pkgs.fetchFromGitHub { owner = "catppuccin"; repo = "sddm"; ... };
  #   installPhase = ''
  #     mkdir -p $out/share/sddm/themes
  #     cp -r $src/src/mocha $out/share/sddm/themes/catppuccin-mocha
  #   '';
  #   meta.description = "Catppuccin Mocha theme for SDDM";
  # };

  # Wichtig: Damit die Overlays wirksam werden, müssen die Pakete
  # entweder direkt hier referenziert werden (z.B. `pkgs.myCustomNeovim`)
  # oder das Overlay muss in `nixpkgs.overlays` in `flake.nix` eingebunden werden.
  # Die aktuelle Struktur mit `overlays.default = import ./overlays/default.nix;` in `flake.nix`
  # und der Verwendung von `nixpkgs.legacyPackages.${system}.extend self.overlays.default` (implizit durch Flakes)
  # sollte dies handhaben.
}
