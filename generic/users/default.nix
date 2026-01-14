{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:
with lib;
let
  sshIdentity = keyname: "~/.ssh/keys/${keyname}.pub";
in
{
  imports = [ ./stylix_fix.nix ];
  home.file = {
    ".ssh/keys".source = ../sshPubkeys;
    #".zshrc".source = ./zshrc;
  };

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    initContent = "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh";
    localVariables = {
      YSU_IGNORED_ALIASES = [ "g" ];
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = osConfig.sops.age.keyFile;
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = rec {
        cat-laptop = {
          user = "cathach";
          identityFile = sshIdentity "support";
        };
        stereoanlage = {
          user = "root";
          hostname = "stereoanlage.localdomain";
          identityFile = sshIdentity "id_ed25519_kodi";
        };
        vps = {
          user = "root";
          hostname = "212.227.135.200";
          identityFile = sshIdentity "id_strato";
        };
        rescueIso = {
          user = "nixos";
          identityFile = sshIdentity "support";
          forwardAgent = true;
        };
        streaming = {
          hostname = "petronillastreaming";
          user = "streaming";
          identityFile = sshIdentity "support";
          forwardAgent = true;
        };
        jasmine = {
          hostname = "jasmine-laptop";
          user = "jasmine";
          identityFile = sshIdentity "support";
          forwardAgent = true;
        };
        "github.com" = {
          #hostname = "ssh.github.com";
          user = "git";
          port = 22;
          identityFile = sshIdentity "github";
        };
        r-desktop = {
          hostname = "r-desktop";
          identityFile = sshIdentity "r-desktop-ed25519";
          forwardAgent = true;
        };
        surface = {
          hostname = "surface-raoul-nixos";
          identityFile = sshIdentity "Surface_id_ed25519";
          forwardAgent = true;
        };
        honermannmedia = {
          hostname = "honermannmedia";
          user = "root";
          identityFile = sshIdentity "id_ed25519_kodi";
        };

        lenovo-linux = {
          hostname = "lenovo-linux";
          identityFile = sshIdentity "id_rsa_lenovo-linux";
          forwardAgent = true;
        };
        sylvia-fujitsu = {
          hostname = "sylvia-fujitsu";
          user = "sylvia";
          identityFile = [
            (sshIdentity "id_rsa_sylvia")
            (sshIdentity "ch-fujitsu")
          ];
          forwardAgent = true;
        };
        server = {
          #match = ''exec "grepcidr '192.168.3.1/24 fd00::4:1/112' <(host %h) <(echo %h) &>/dev/null"'';
          hostname = "server";
          identityFile = [
            (sshIdentity "id_ecdsa_proxmox")
            (sshIdentity "ch-kodi")
          ];
          user = "root";
          forwardAgent = true;
        };
        server-extern = server // {
          hostname = "honermann.info";
        };
        "*" = {
          forwardAgent = false;
          identitiesOnly = true;
        };
      };
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
