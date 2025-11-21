{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
in
{
  options.age.secrets = lib.mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "Just a dummy for the module";
  };
  imports = [ inputs.github-nix-ci.nixosModules.default ];
  config = {
    sops.secrets.github-runner-key.sopsFile = ../secrets/r-desktop/github.yaml;
    services.github-nix-ci = {
      runnerSettings.extraPackages = with pkgs; [ gh ];
      age.secretsDir = null;
      personalRunners = {
        "RaHoni/nixos-conf" = {
          num = 3;
          tokenFile = config.sops.secrets.github-runner-key.path;
        };
      };
    };

    environment.persistence."/permament".directories = [ "/var/lib/private/github-runner" ];
  };
}
