{ config, pkgs, lib, osConfig, ... }:
with lib;
let
  sshIdentity = keyname: "~/.ssh/keys/${keyname}.pub";
in
{
  home.file = {
    ".ssh/keys".source = ../sshPubkeys;
    ".p10k.zsh".source = ./p10k.zsh;
    ".zshrc".source = ./zshrc;
  };

  home.packages = with pkgs; [
    grepcidr
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      extraConfig = "user raoul";
      matchBlocks = rec {
        streaming = {
          hostname = "petronillastreaming.nb.honermann.info";
          user = "streaming";
          identityFile = sshIdentity "support";
          identitiesOnly = true;
          forwardAgent = true;
        };
        jasmine = {
          hostname = "jasmine-laptop.nb.honermann.info";
          user = "jasmine";
          identityFile = sshIdentity "support";
          identitiesOnly = true;
          forwardAgent = true;
        };
        "github.com" = {
          #hostname = "ssh.github.com";
          user = "git";
          port = 22;
          identityFile = sshIdentity "github";
          identitiesOnly = true;
        };
        r-desktop = {
          hostname = "r-desktop.nb.honermann.info";
          identityFile = sshIdentity "r-desktop-ed25519";
          identitiesOnly = true;
          forwardAgent = true;
        };
        surface = {
          hostname = "surface-raoul-nixos.nb.honermann.info";
          identityFile = sshIdentity "Surface_id_ed25519";
          identitiesOnly = true;
          forwardAgent = true;
        };
        ffmpeg = {
          hostname = r-desktop.hostname;
          user = "ffmpeg";
          identityFile = sshIdentity "id_ffmpeg";
          identitiesOnly = true;
          forwardAgent = true;
        };
        honermannmedia = {
          hostname = "192.168.2.37";
          user = "root";
          identityFile = sshIdentity "id_ed25519_kodi";
          identitiesOnly = true;
        };

        lenovo-linux = {
          hostname = "lenovo-linux.fritz.box";
          identityFile = sshIdentity "id_rsa_lenovo-linux";
          identitiesOnly = true;
          forwardAgent = true;
        };
        "keys.inckmann.de" = {
          hostname = "212.227.215.39";
          user = "root";
          identityFile = sshIdentity "id_ed25519_keys_inkmann";
          identitiesOnly = true;
          forwardAgent = true;
        };
        sylvia-fujitsu = {
          hostname = "sylvia-fujitsu.fritz.box";
          user = "sylvia";
          identityFile = sshIdentity "id_rsa_sylvia";
          identitiesOnly = true;
          forwardAgent = true;
        };
        raspberry = {
          hostname = "192.168.2.80";
          user = "root";
          identityFile = sshIdentity "id_ed25519_raspberry";
          identitiesOnly = true;
          forwardAgent = true;
        };
        proxmox = {
          match = ''exec "grepcidr '192.168.3.1/24 fd00::4:1/112' <(host %h) <(echo %h) &>/dev/null"'';
          identityFile = sshIdentity "id_ecdsa_proxmox";
          user = "root";
          identitiesOnly = true;
          forwardAgent = true;
        };
      };
    };


    git = {
      enable = true;
      extraConfig = {
        push = { autoSetupRemote = true; };
        pull = { rebase = true; };
      };
    };
  };

  # Signal start in tray fix
  home.file.".local/share/applications/signal-desktop.desktop" = {
    enable = osConfig.services.xserver.desktopManager.plasma5.enable;
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

