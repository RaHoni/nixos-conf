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
  home.file = {
    ".ssh/keys".source = ../sshPubkeys;
    ".p10k.zsh".source = ./p10k.zsh;
    #".zshrc".source = ./zshrc;
  };

  home.packages = with pkgs; [
    grepcidr
  ];

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    initExtra = "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh";
    localVariables = {
      YSU_HARDCORE = 1;
      YSU_IGNORED_ALIASES = [ "g" ];
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      extraConfig = ''
        user raoul
        identitiesOnly yes
      '';
      matchBlocks = rec {
        cat-laptop = {
          user = "cathach";
          identityFile = sshIdentity "support";
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
          hostname = "petronillastreaming.nb.honermann.info";
          user = "streaming";
          identityFile = sshIdentity "support";
          forwardAgent = true;
        };
        jasmine = {
          hostname = "jasmine-laptop.nb.honermann.info";
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
          hostname = "r-desktop.nb.honermann.info";
          identityFile = sshIdentity "r-desktop-ed25519";
          forwardAgent = true;
        };
        surface = {
          hostname = "surface-raoul-nixos.nb.honermann.info";
          identityFile = sshIdentity "Surface_id_ed25519";
          forwardAgent = true;
        };
        ffmpeg = {
          hostname = r-desktop.hostname;
          user = "ffmpeg";
          identityFile = sshIdentity "id_ffmpeg";
          forwardAgent = true;
        };
        honermannmedia = {
          hostname = "honermannmedia.localdomain";
          user = "root";
          identityFile = sshIdentity "id_ed25519_kodi";
        };

        lenovo-linux = {
          hostname = "lenovo-linux.localdomain";
          identityFile = sshIdentity "id_rsa_lenovo-linux";
          forwardAgent = true;
        };
        sylvia-fujitsu = {
          hostname = "sylvia-fujitsu.localdomain";
          user = "sylvia";
          identityFile = sshIdentity "id_rsa_sylvia";
          forwardAgent = true;
        };
        server = {
          #match = ''exec "grepcidr '192.168.3.1/24 fd00::4:1/112' <(host %h) <(echo %h) &>/dev/null"'';
          hostname = "192.168.1.14";
          identityFile = sshIdentity "id_ecdsa_proxmox";
          user = "root";
          forwardAgent = true;
        };
      };
    };

    git = {
      enable = true;
      extraConfig = {
        push = {
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
      };
    };
  };

  # Signal start in tray fix
  home.file.".local/share/applications/signal-desktop.desktop" = {
    enable = osConfig.services.desktopManager.plasma6.enable;
    text = ''
      [Desktop Entry]
      Name=Signal
      Exec=LANGUAGE="de-DE:en-US" ${pkgs.signal-desktop}/bin/signal-desktop --no-sandbox --start-in-tray %U
      Terminal=false
      Type=Application
      Icon=signal-desktop
      StartupWMClass=Signal
      Comment=Private messaging from your desktop
      MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
      Categories=Network;InstantMessaging;Chat;
    '';
  };
}
