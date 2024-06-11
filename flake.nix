{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    #nixpkgs-ffmpeg.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    plasma-manager-stable.url = "github:pjones/plasma-manager";
    plasma-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    plasma-manager-stable.inputs.home-manager.follows = "home-manager-stable";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nixvim-stable = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    private-nixpkgs.url = "github:rahoni/nixpkgs/baculaTls";
    #private-nixpkgs.url = "/home/raoul/Programmieren/nixos/nixpkgs";

    nix-on-droid.url = "github:nix-community/nix-on-droid/release-23.05";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home-manager";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    streamdeck-obs.url = "github:RaHoni/streamdeck";
    streamdeck-obs.inputs.nixpkgs.follows = "nixpkgs-stable";

  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://rahoni.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
      "https://rahoni.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "rahoni.cachix.org-1:iCKI8r6HT5rToodXfecglGJnPTaOaGzNeAS5wawMuMM="
    ];
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let
      pkgsConfig = pkgs: system: import pkgs {
        overlays = [
          (import ./generic/overlays)
        ];
        inherit system;
        config = {
          allowUnfree = true; #allow Unfree packages
        };
      };

      stable-nixpkgs = system: pkgsConfig nixpkgs-stable system;
      overlays = system: final: prev: {
        stable = pkgsConfig nixpkgs-stable system;
        unstable = pkgsConfig nixpkgs system;
        ffmpeg-vpl = import nixpkgs {
          overlays = [ (import ./generic/overlays/ffmpeg.nix) ];
          inherit system;
          config.allowUnfree = true;
          modules = [
            ./generic
          ];
        };
      };

      makeSystem = { systemModules, homeManagerModules ? { }, stable ? true, proxmox ? false, system ? "x86_64-linux", nebula ? false, ... }: nixpkgs-stable.lib.nixosSystem rec {
        pkgs = if stable then pkgsConfig nixpkgs-stable system else pkgsConfig nixpkgs system;
        inherit system;
        specialArgs = {
          inherit inputs stable nebula; #ToDO: also make proxmox an option
          homeManagerModules = nixpkgs.lib.attrsets.foldAttrs (item: acc: item ++ acc) [ ] [
            {
              root = [
                ./generic/users/root/home-manager.nix
              ];
            }
            homeManagerModules
          ];
        };
        modules = [
          ./generic/newDefault.nix
          ./generic/nebula.nix
        ]
        ++ systemModules
        ++ nixpkgs.lib.lists.optionals proxmox [ ./generic/proxmox.nix ];
      };
    in
    rec {
      nixosConfigurations = {
        surface-raoul-nixos = makeSystem {
          systemModules = [
            ./surface-raoul-nixos/configuration.nix
            ./generic/pim.nix
            nixos-hardware.nixosModules.microsoft-surface-go
          ];
          homeManagerModules = {
            raoul = [
              ./surface-raoul-nixos/raoulHM.nix
              plasma-manager-stable.homeManagerModules.plasma-manager
            ];
          };
          nebula = true;
        };


        r-desktop = makeSystem {
          systemModules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ (overlays "x86_64-linux") ]; })
            ./r-desktop/configuration.nix
            ./r-desktop/bacula.nix
            ./r-desktop/pio.nix
            ./r-desktop/incron.nix
            ./generic/pim.nix
          ];
          homeManagerModules = {
            raoul = [
              ./r-desktop/raoulHM.nix
              plasma-manager-stable.homeManagerModules.plasma-manager
              ./generic/users/obs.nix
            ];
            ffmpeg = [ ./generic/users ];
          };
          nebula = true;
          stable = true;
        };

        jasmine-laptop = makeSystem {
          systemModules = [
            ./jasmine/default.nix
          ];
          homeManagerModules = {
            jasmine = [ ./jasmine/jasmineHM.nix ];
          };
          nebula = true;
        };

        smb = makeSystem {
          systemModules = [
            ./smb/default.nix
          ];
          proxmox = true;
        };
        audiobooks = makeSystem {
          systemModules = [
            ./audiobooks/default.nix
          ];
          proxmox = true;
        };
        ssl-proxy = makeSystem {
          systemModules = [
            ./proxy/default.nix
            ./generic/proxy.nix
          ];
          proxmox = true;
        };
        nebula-lighthouse = makeSystem {
          systemModules = [
            ./nebula-lighthouse/configuration.nix
          ];
          nebula = true;
          proxmox = true;
        };

        nextcloud = makeSystem {
          systemModules = [
            ./nextcloud/default.nix
          ];
          proxmox = true;
          stable = false;
        };

        petronillaStreaming = makeSystem {
          systemModules = [
            ./petronillaStreaming/configuration.nix
            ./petronillaStreaming/users.nix
            ./generic/nvidea.nix
          ];
          homeManagerModules.streaming = [
            ./generic/users/default.nix
            ./generic/users/obs.nix
            plasma-manager-stable.homeManagerModules.plasma-manager
            ./petronillaStreaming/hm-streaming.nix
          ];
          nebula = true;
        };

        rescueIso = makeSystem {
          systemModules = [
            ./rescueIso/configuration.nix
            "${nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix"
          ];
          homeManagerModules = {
            nixos = [
              ./generic/users/default.nix
            ];
          };
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
