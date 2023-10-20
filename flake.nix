{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    plasma-manager.inputs.home-manager.follows = "home-manager-stable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    private-nixpkgs.url = "github:rahoni/nixpkgs";

  };

  outputs = { self, ... }@inputs:
    with inputs; {
      nixosConfigurations.surface-raoul-nixos = nixpkgs-stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        pkgs = import nixpkgs-stable {
          overlays = [
            (import ./generic/overlays.nix)
          ];
          inherit system;
          config = {
            allowUnfree = true; #allow Unfree packages
          };
        };
        specialArgs = inputs;
        modules = [
          ./surface-raoul-nixos/configuration.nix
          ./generic/sops.nix
          sops-nix.nixosModules.sops
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              users = {
                raoul = import ./generic/raoul/home-manager.nix;
              };
            };
          }
        ];
      };

    };
}
