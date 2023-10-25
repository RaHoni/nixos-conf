{ config, pkgs, lib, ... }:
with lib;
let
  sshIdentity = keyname: "~/.ssh/keys/${keyname}.pub";
in
{
  home.file = {
    ".ssh/keys".source = ../sshPubkeys;
    ".p10k.zsh".source = ./p10k.zsh;
  };

  home.packages = with pkgs; [
    grepcidr
  ];

  programs = {
    ssh = {
      enable = true;
      extraConfig = "user raoul";
      matchBlocks = {
        "github.com" = {
          #hostname = "ssh.github.com";
          user = "git";
          port = 22;
          identityFile = sshIdentity "github";
          identitiesOnly = true;
        };
        r-desktop = {
          hostname = "honermann.info";
          identityFile = sshIdentity "r-desktop-ed25519";
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
        proxmox = {
          match = ''exec "grepcidr '192.168.3.1/24 fd00::4:1/112' <(host %h) <(echo %h) &>/dev/null"'';
          identityFile = sshIdentity "id_ecdsa_proxmox";
          user = "root";
          identitiesOnly = true;
          forwardAgent = true;
        };
      };
    };
  };
}

