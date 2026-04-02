{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  imports = [
    ./stylix_fix.nix
    ./ssh.nix
  ];
  home.file = {
    ".ssh/keys".source = ../sshPubkeys;
    #".zshrc".source = ./zshrc;
  };

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    initContent = "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    compdef _restic ${
          builtins.concatStringsSep " " (
            lib.mapAttrsToList (name: _: "restic-${name}") (
              lib.filterAttrs (_: v: v.createWrapper) osConfig.services.restic.backups
            )
          )
        }";

    localVariables = {
      YSU_IGNORED_ALIASES = [ "g" ];
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = osConfig.sops.age.keyFile;
  };

  programs = {
    direnv = {
      enable = osConfig.local.full;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      settings = {
        credential = {
          helper = "store --file=/run/secrets/git-credentials";
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
      };
    };
  };

}
