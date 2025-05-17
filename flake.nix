# nixos-config/flake.nix
{
  description = "NixOS configuration for multiple hosts and desktops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Oder eine stabilere Version wie nixos-23.11 oder die aktuelle
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    # Optional: Weitere Inputs für spezielle Overlays oder Plugins
    # z.B. catppuccin-kde-theme = { url = "github:catppuccin/kde"; flake = false; }; # Beispiel für ein Theme
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Systemarchitektur (kann pro Host überschrieben werden, falls nötig)
      system = "x86_64-linux";

      # Hilfsfunktion zum Erstellen von Systemkonfigurationen
      mkSystem = { hostname, currentSystemName, specialArgs ? {}, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; currentSystem = currentSystemName; } // specialArgs;
          modules = [
            # Host-spezifische Konfiguration (importiert jetzt default.nix aus dem Host-Verzeichnis)
            ./hosts/${hostname}/default.nix
            # Gemeinsame Module
            ./modules/nixos/common.nix
            ./modules/nixos/services/audio.nix
            ./modules/nixos/services/bluetooth.nix
            ./modules/nixos/services/cups.nix
            ./modules/nixos/services/flatpak.nix
            ./modules/nixos/services/firewall.nix
            ./modules/nixos/services/ssd.nix
            ./modules/nixos/services/virtualization.nix
            ./modules/nixos/security.nix
            ./modules/nixos/gaming.nix
            # Home Manager Modul für NixOS
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = { inherit inputs; inherit hostname; currentSystem = currentSystemName; }; # hostname und currentSystem für Home Manager
              home-manager.users.nick = import ./modules/home-manager/nick/default.nix;
            }
          ] ++ modules; # Zusätzliche Module (z.B. Desktop-Umgebungen)
        };
    in
    {
      # NixOS Konfigurationen
      # Ermöglicht Builds wie: nixos-rebuild switch --flake .#host1-kde
      nixosConfigurations = {
        # Host1 Konfigurationen
        host1-kde = mkSystem {
          hostname = "host1";
          currentSystemName = "host1-kde";
          modules = [ ./modules/desktops/kde.nix ];
        };
        host1-gnome = mkSystem {
          hostname = "host1";
          currentSystemName = "host1-gnome";
          modules = [ ./modules/desktops/gnome.nix ];
        };
        host1-hyprland = mkSystem {
          hostname = "host1";
          currentSystemName = "host1-hyprland";
          modules = [ ./modules/desktops/hyprland.nix ];
        };

        # Host2 Konfigurationen
        host2-kde = mkSystem {
          hostname = "host2";
          currentSystemName = "host2-kde";
          modules = [ ./modules/desktops/kde.nix ];
        };
        host2-gnome = mkSystem {
          hostname = "host2";
          currentSystemName = "host2-gnome";
          modules = [ ./modules/desktops/gnome.nix ];
        };
        host2-hyprland = mkSystem {
          hostname = "host2";
          currentSystemName = "host2-hyprland";
          modules = [ ./modules/desktops/hyprland.nix ];
        };
      };

      # Direkte Home-Manager Konfiguration (für standalone home-manager builds)
      homeConfigurations."nick@host1" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; hostname = "host1"; currentSystem = "host1-kde"; }; # currentSystem hier als Fallback
        modules = [ ./modules/home-manager/nick/default.nix ];
      };
      homeConfigurations."nick@host2" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs; hostname = "host2"; currentSystem = "host2-kde"; }; # currentSystem hier als Fallback
        modules = [ ./modules/home-manager/nick/default.nix ];
      };

      # Overlays (optional)
      overlays.default = import ./overlays/default.nix;
    };
}
