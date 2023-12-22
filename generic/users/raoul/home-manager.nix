{ config, pkgs, lib, home-manager-stable, ... }:
with lib;
{
  imports = [ ./../default.nix ./plasma.nix ];
  home.stateVersion = "23.05";
  home.file.".config/kate/lspclient/settings.json".text = ''
      {
        "servers": {
            "nix": {
                "command": ["rnix-lsp"],
    "highlightingModeRegex": "^nix$"
    }
    }
    }

  '';

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
    extraConfig = "no-grab";
    maxCacheTtl = 604800;
    defaultCacheTtl = 604800;
  };

  programs = {
    gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;
    };

    git = {
      enable = true;
      userName = "RaHoni";
      userEmail = "honisuess@gmail.com";
      signing = {
        key = "54D11CB37C713D5457ACF0C35962F3E9516FD551";
        signByDefault = true;
      };
      extraConfig = {
        push = { autoSetupRemote = true; };
        pull = { rebase = true; };
      };
    };
  };
}
