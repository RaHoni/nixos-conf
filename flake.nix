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
  };

  outputs = { self, nixpkgs-stable, home-manager-stable, ... }@attrs: {
    nixosConfigurations.surface-raoul-nixos = nixpkgs-stable.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = import nixpkgs-stable {
        overlays = [
          (final: prev: {
            zsh-powerlevel10k = prev.zsh-powerlevel10k.overrideAttrs {
              #    pname = "powerlevel10k-raoul";
              installPhase = ''
                install -D powerlevel10k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
                install -D powerlevel9k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
                install -D config/* --target-directory=$out/share/zsh/themes/powerlevel10k/config
                install -D internal/* --target-directory=$out/share/zsh/themes/powerlevel10k/internal
                cp -R gitstatus $out/share/zsh/themes/powerlevel10k/gitstatus
              '';
            };
            zsh-nix-shell = prev.zsh-nix-shell.overrideAttrs {
              installPhase = ''
                install -D nix-shell.plugin.zsh --target-directory=$out/share/zsh/plugins/nix-shell
                install -D scripts/* --target-directory=$out/share/zsh/plugins/nix-shell/scripts
              '';
            };
          }
          )
        ];
        inherit system;
        config = {
          allowUnfree = true; #allow Unfree packages
        };
      };
      specialArgs = attrs;
      modules = [ ./configuration.nix ./nextcloud.nix ];
    };
  };
}
