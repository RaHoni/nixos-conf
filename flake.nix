{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-ffmpeg.url = "github:evanrichter/nixpkgs/libvpl-for-intel-gpu";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
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
    #private-nixpkgs.url = "/home/raoul/Programmieren/nixos/nixpkgs";

    nix-on-droid.url = "github:nix-community/nix-on-droid/release-23.05";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home-manager";

  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      stable-nixpkgs = system: import nixpkgs-stable {
        overlays = [
          (import ./generic/overlays)
        ];
        inherit system;
        config = {
          allowUnfree = true; #allow Unfree packages
        };
      };
      overlay-ffmpeg = final: prev: {
        ffmpeg-vpl = import nixpkgs-ffmpeg {
          overlays = [ (import ./generic/overlays/ffmpeg.nix) ];
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
    in
    rec {
      nixosConfigurations = {
        surface-raoul-nixos = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";
          pkgs = stable-nixpkgs system;
          specialArgs = inputs;
          modules = [
            ./surface-raoul-nixos/configuration.nix
            ./generic
            ./generic/nebula.nix
            ./generic/pim.nix
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "bak";
                sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                users = {
                  raoul = import ./generic/users/raoul/home-manager.nix;
                  root = import ./generic/users/root/home-manager.nix;
                };
              };
            }
          ];
        };

        r-desktop = nixpkgs-stable.lib.nixosSystem rec {
          system = "x86_64-linux";
          pkgs = stable-nixpkgs system;
          specialArgs = inputs;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-ffmpeg ]; })
            ./r-desktop/configuration.nix
            ./r-desktop/bacula.nix
            ./r-desktop/pio.nix
            ./generic
            ./generic/nebula.nix
            ./generic/pim.nix
            home-manager-stable.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                backupFileExtension = "bak";
                sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
                users = {
                  raoul = import ./generic/users/raoul/home-manager.nix;
                  root = import ./generic/users/root/home-manager.nix;
                  ffmpeg = import ./r-desktop/ffmpeg-home.nix;
                };
              };
            }
          ];
        };

        packete = nixpkgs-stable.lib.nixosSystem
          rec {
            system = "x86_64-linux";
            pkgs = stable-nixpkgs system;
            specialArgs = inputs;
            modules = [
              ./packete/configuration.nix
              ./generic
              ./generic/proxmox.nix
              home-manager-stable.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "bak";
                  useGlobalPkgs = true;
                  users = {
                    root = import ./generic/users/root/home-manager.nix;
                  };
                };
              }
            ];
          };
        smb = nixpkgs-stable.lib.nixosSystem
          rec {
            system = "x86_64-linux";
            pkgs = stable-nixpkgs system;
            specialArgs = inputs;
            modules = [
              ./smb
              ./generic
              ./generic/proxmox.nix
              home-manager-stable.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "bak";
                  useGlobalPkgs = true;
                  users.root = import ./generic/users/root/home-manager.nix;
                };
              }
            ];
          };


        raspberry = nixpkgs-stable.lib.nixosSystem
          rec {
            system = "aarch64-linux";
            pkgs = stable-nixpkgs system;
            specialArgs = inputs;
            modules = [
              ./raspberry/configuration.nix
              ./generic/default.nix
              ./generic/nebula.nix
              home-manager-stable.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "bak";
                  useGlobalPkgs = true;
                  users = {
                    root = import ./generic/users/root/home-manager.nix;
                  };
                };
              }
            ];
          };

        aarch64-image = nixpkgs-stable.lib.nixosSystem
          {
            modules = [
              ./iso/configuration.nix
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
              {
                nixpkgs.config.allowUnsupportedSystem = true;
                nixpkgs.hostPlatform.system = "aarch64-linux";
                nixpkgs.buildPlatform.system = "x86_64-linux"; #If you build on x86 other wise changes this.
                # ... extra configs as above

              }
            ];
          };
      };

      nixOnDroidConfigurations.fp4 = nix-on-droid.lib.nixOnDroidConfiguration {
        system = "aarch64-linux";
        pkgs = stable-nixpkgs "aarch64-linux";
        modules = [
          ./fp4
          ./generic
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              backupFileExtension = "bak";
              sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              imports = [
                ../generic/users/raoul/home-manager.nix
              ];
            };
          }
        ];
      };

      images.raspberry = nixosConfigurations.aarch64-image.config.system.build.sdImage;

    };
}
