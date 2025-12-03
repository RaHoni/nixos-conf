{ ... }:
let
  gitHelper = "!/etc/profiles/per-user/raoul/bin/gh auth git-credential";
in
{
  imports = [
    ../generic/users/raoul/home-manager.nix
    ../generic/neovim.nix
  ];
}
