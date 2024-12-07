{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-bacula.url = "github:RaHoni/nixpkgs/bacula";
    nixpkgs-master.url = "github:NixOS/nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    hydra.url = "github:NixOS/hydra";

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
      url = "github:nix-community/nixvim/nixos-24.11";
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

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    streamdeck-obs = {
      url = "github:RaHoni/streamdeck";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://binarycache.honermann.info"
      "https://rahoni.cachix.org"
    ];
    extra-trusted-substituters = [
      "https://binarycache.honermann.info"
      "https://rahoni.cachix.org"
    ];
    extra-trusted-public-keys = [
      "binarycache.honermann.info:ta4rxqLXx+RoTmZjybD96dm0fwcpTDQqFnF3HBRTeWg="
      "rahoni.cachix.org-1:iCKI8r6HT5rToodXfecglGJnPTaOaGzNeAS5wawMuMM="
    ];
  };

  outputs =
    { self, systems, ... }@inputs:
    with inputs;
    let
      inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs elem;
      getCfg = _: cfg: cfg.config.system.build.toplevel;
      pkgsConfig =
        pkgs: system:
        import pkgs {
          overlays = [
            (import ./generic/overlays)
            mprisRecord.overlays.${system}.default
          ];
          inherit system;
          config = {
            allowUnfree = true; # allow Unfree packages
          };
        };

      stable-nixpkgs = system: pkgsConfig nixpkgs-stable system;
      overlays = system: final: prev: {
        master = pkgsConfig nixpkgs-master system;
        stable = pkgsConfig nixpkgs-stable system;
        unstable = pkgsConfig nixpkgs system;
        ffmpeg-vpl = import nixpkgs-stable {
          overlays = [ (import ./generic/overlays/ffmpeg.nix) ];
          inherit system;
          config.allowUnfree = true;
          modules = [
            ./generic
          ];
        };
      };

      makeSystem =
        {
          systemModules,
          homeManagerModules ? { },
          stable ? true,
          proxmox ? false,
          system ? "x86_64-linux",
          nebula ? false,
          secureboot ? false,
          genericHomeManagerModules ? [ ],
          ...
        }:
        nixpkgs-stable.lib.nixosSystem rec {
          pkgs = if stable then pkgsConfig nixpkgs-stable system else pkgsConfig nixpkgs system;
          inherit system;
          specialArgs = {
            inherit
              inputs
              stable
              nebula
              secureboot
              genericHomeManagerModules
              ; # ToDO: also make proxmox an option
            inherit (hydra.packages.${system}) hydra;
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
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ (overlays system) ];
              }
            )
            ./generic/newDefault.nix
            ./generic/nebula.nix
          ] ++ systemModules ++ nixpkgs.lib.lists.optionals proxmox [ ./generic/proxmox.nix ];
        };

      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    rec {
      nixosConfigurations = {
        surface-raoul-nixos = makeSystem {
          systemModules = [
            ./surface-raoul-nixos/configuration.nix
            ./generic/localisation.nix
            #./generic/pipewire.nix
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
            stylix.nixosModules.stylix
          ];
          homeManagerModules = {
            raoul = [
              plasma-manager-stable.homeManagerModules.plasma-manager
              ./generic/users/raoul/home-manager.nix
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
            ./server/esphome.nix
            ./server/github-runner.nix
            ./server/home-assistant.nix
            ./server/hydra.nix
            ./server/pi-hole.nix
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
            ./raoul-framework/factorio.nix
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

        server = makeSystem {
          systemModules = [
            inputs.impermanence.nixosModules.impermanence
            ./bacula/dir.nix
            ./bacula/sd.nix
            ./server
            ./server/bacula.nix
            ./server/home-assistant.nix
            ./server/nextcloud.nix
          ];
        };

        nextcloud = makeSystem {
          systemModules = [
            ./server/bacula.nix
            ./server/nextcloud.nix
            ./nextcloud/default.nix
            #./server/smb.nix
            #./server/calibre.nix
            #./server/audiobookshelf.nix
            ./bacula/dir.nix
            ./bacula/sd.nix
            ./generic/smtp.nix
            #./server/pi-hole.nix
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
      };

      packages = {
        x86_64-linux = rec {
          default = installer;
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
              genericHomeManagerModules = [ ];
              homeManagerModules = {
                root = [ ./generic/users/root/home-manager.nix ];
                nixos = [ ./generic/users/default.nix ];
              };
            };
          };
          arch-installer = nixos-generators.nixosGenerate rec {
            pkgs = pkgsConfig nixpkgs-stable system;
            format = "sd-aarch64-installer";
            system = "aarch64-linux";
            modules = [
              ./generic/newDefault.nix
              ./generic/nebula.nix
              { networking.hostName = "rescueIso"; }
            ];
            specialArgs = {
              inherit system inputs;
              nebula = false;
              stable = true;
              secureboot = false;
              genericHomeManagerModules = [ ];
              homeManagerModules = {
                root = [ ./generic/users/root/home-manager.nix ];
                nixos = [ ./generic/users/default.nix ];
              };
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

      checks = nixpkgs.lib.genAttrs (import systems) (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          addGcRoot = true;
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      devShells = nixpkgs.lib.genAttrs (import systems) (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          packages = with (stable-nixpkgs system); [ kdiff3 ];
        };
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-rfc-style);

      hydraJobs = {
        # Include filtered configurations as Hydra jobs
        hosts = mapAttrs getCfg nixosConfigurations;
        #inherit (nixosConfigurations) r-desktop;
        # Each filtered configuration is available as a job
        inherit devShells packages;
      };

      images.raspberry = nixosConfigurations.aarch64-image.config.system.build.sdImage;
    };
}
