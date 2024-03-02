{ ... }: 
let 
  gitHelper = "!/etc/profiles/per-user/raoul/bin/gh auth git-credential";
in 
{
  imports = [ ../generic/users/raoul/home-manager.nix ../generic/neovim.nix ];
  programs.git.extraConfig = {
"credential \"https://github.com\"".helper = "${gitHelper}";
"credential \"https://gist.github.com\"".helper = "${gitHelper}";
  };
  
}


