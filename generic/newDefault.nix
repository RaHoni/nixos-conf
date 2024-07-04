{ config, pkgs, inputs, homeManagerModules, stable, nebula, ... }:

{
  # import common.nix and home manager module depending on if system uses stable or unstable packages
  imports = if stable then [ inputs.home-manager-stable.nixosModules.home-manager ./default.nix ] else [ inputs.home-manager.nixosModules.home-manager ./default.nix ];

  #set zsh as default shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  system.configurationRevision = inputs.self.shortRev or inputs.self.dirtyShortRev;

  boot.supportedFilesystems = [ "exfat" ];

  local.nebula.enable = nebula;
  #home manager setup
  programs.dconf.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    /*
      homeextraSpecialArgs = {
      #pass nixneovim as additional Arg to home-manager config
      inherit nixvim;
      }
    */
    /*
      homeManagerModules is a attribute set of users which are lists of paths to import into home manager
      the following will change the users to attribute sets with home manager config
    */
    users = builtins.mapAttrs
      (userName: modules:
        {
          imports = if stable then modules ++ [ inputs.nixvim-stable.homeManagerModules.nixvim ] else modules ++ [ inputs.nixvim.homeManagerModules.nixvim ];

          home.username = userName;
          home.homeDirectory = if userName == "root" then "/root" else "/home/${userName}";

          programs.home-manager.enable = true;
          home.stateVersion = config.system.stateVersion;
        }
      )
      homeManagerModules;
  };

}
