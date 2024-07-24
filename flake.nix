{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-bacula.url = "github:RaHoni/nixpkgs/bacula";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote-stable = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    mprisRecord = {
      url = "github:RaHoni/mprisRecord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-stable = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    plasma-manager-stable = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        home-manager.follows = "home-manager-stable";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    streamdeck-obs = {
      url = "github:RaHoni/streamdeck";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
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
          mprisRecord.overlays.${system}.default
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

      makeSystem = { systemModules, homeManagerModules ? { }, stable ? true, proxmox ? false, system ? "x86_64-linux", nebula ? false, secureboot ? false, ... }: nixpkgs-stable.lib.nixosSystem rec {
        pkgs = if stable then pkgsConfig nixpkgs-stable system else pkgsConfig nixpkgs system;
        inherit system;
        specialArgs = {
          inherit inputs stable nebula secureboot; #ToDO: also make proxmox an option
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
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ (overlays system) ]; })
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
            ./generic/localisation.nix
            ./generic/pipewire.nix
            ./generic/plasma.nix
            ./generic/printer.nix
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

        raoul-framework = makeSystem {
          systemModules = [
            ./raoul-framework/configuration.nix
            ./raoul-framework/disko.nix
            ./generic/localisation.nix
            ./generic/pipewire.nix
            ./generic/plasma.nix
            ./generic/printer.nix
            ./raoul-framework/hardwareconfig.nix
            nixos-hardware.nixosModules.framework-16-7040-amd
          ];
          homeManagerModules = {
            raoul = [
              plasma-manager-stable.homeManagerModules.plasma-manager
              ./generic/users/raoul/home-manager.nix
              ./generic/neovim.nix
              ./generic/users/pandoc.nix
              ./generic/users/raoul/plasma6.nix
            ];
          };
          nebula = true;
          secureboot = true;
        };

        r-desktop = makeSystem {
          systemModules = [
            ./r-desktop/bacula.nix
            ./r-desktop/configuration.nix
            ./r-desktop/incron.nix
            ./r-desktop/pio.nix
            ./generic/intelgpu.nix
            ./generic/localisation.nix
            ./generic/pipewire.nix
            ./generic/plasma.nix
            ./generic/printer.nix
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
            #./server/smb.nix
            #./server/calibre.nix
            #./server/audiobookshelf.nix
            ./bacula/dir.nix
            ./bacula/sd.nix
            ./generic/smtp.nix
          ];
          proxmox = true;
          stable = true;
        };

        petronillaStreaming = makeSystem {
          systemModules = [
            ./petronillaStreaming/configuration.nix
            ./petronillaStreaming/users.nix
            ./generic/nvidea.nix
            ./generic/pipewire.nix
            ./generic/plasma.nix
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

      packages.x86_64-linux = {
        installer = nixos-generators.nixosGenerate rec {
          pkgs = pkgsConfig nixpkgs-stable system;
          format = "install-iso";
          system = "x86_64-linux";
          modules = [
            ./generic/newDefault.nix
            ./generic/nebula.nix
            ./rescueIso/configuration.nix
            "${nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          ];
          specialArgs = {
            inherit system inputs;
            nebula = false;
            stable = true;
            secureboot = false;
            homeManagerModules = {
              root = [ ./generic/users/root/home-manager.nix ];
              nixos = [ ./generic/users/default.nix ];
            };
          };
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
