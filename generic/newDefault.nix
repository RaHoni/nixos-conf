{
  config,
  pkgs,
  inputs,
  homeManagerModules,
  stable,
  nebula,
  lib,
  genericHomeManagerModules,
  ...
}:
let
  inherit (lib) optionals;
  switchStable = stableModuls: unstableModuls: if stable then stableModuls else unstableModuls;
in
{
  # import common.nix and home manager module depending on if system uses stable or unstable packages
  imports = [
    ./default.nix
    ./lanzaboote.nix
    ./wireguard.nix # module
    ./autoupgrade.nix # module
  ]
  ++ (switchStable
    [ inputs.home-manager-stable.nixosModules.home-manager ]
    [
      inputs.home-manager.nixosModules.home-manager
    ]
  );

  #set zsh as default shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  system.configurationRevision = inputs.self.shortRev or inputs.self.dirtyShortRev or "null";

  nix.settings = {
    auto-optimise-store = true;
    substituters = [
      "https://nix-community.cachix.org"
      "https://binarycache.honermann.info"
      "https://cache.garnix.io"
    ];
    trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://binarycache.honermann.info"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "binarycache.honermann.info:ta4rxqLXx+RoTmZjybD96dm0fwcpTDQqFnF3HBRTeWg="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];

  };

  boot.supportedFilesystems = [ "exfat" ];

  local.nebula.enable = nebula;
  #home manager setup
  programs.dconf.enable = true;
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    sharedModules = [
      ./neovim.nix
    ]
    ++ genericHomeManagerModules
    ++ (switchStable
      [ inputs.nixvim-stable.homeManagerModules.nixvim ]
      [
        inputs.nixvim.homeManagerModules.nixvim
      ]
    );
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
    users = builtins.mapAttrs (userName: modules: {
      imports = modules ++ [ ./users/default.nix ];

      home.username = userName;
      home.homeDirectory = if userName == "root" then "/root" else "/home/${userName}";

      programs.home-manager.enable = true;
      home.stateVersion = config.system.stateVersion;
    }) homeManagerModules;
  };

}
