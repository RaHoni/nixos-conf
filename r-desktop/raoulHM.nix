{ pkgs, ... }: {
  imports = [ ../generic/users/raoul/home-manager.nix ../generic/neovim.nix ];
  home.packages = with pkgs; [
    handbrake
  ];
}

