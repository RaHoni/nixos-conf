{ pkgs, config, ... }:
let 
  placeholder = config.sops.placeholder;
in
{
  sops = {
    templates.factorio.content = ''
      {
        "username" : "${placeholder.username}",
        "game_password":"${placeholder.game_password}",
        "token":"${placeholder.token}"
      }
      '';
    secrets = {
      username = {
        sopsFile = ../secrets/ssl-proxy/factorio.yaml;
        restartUnits = [ "factorio.service" ];
      };
      game_password = {
        sopsFile = ../secrets/ssl-proxy/factorio.yaml;
        restartUnits = [ "factorio.service" ];
      };
      token = {
        sopsFile = ../secrets/ssl-proxy/factorio.yaml;
        restartUnits = [ "factorio.service" ];
      };
    };
  };
  services.factorio = {
    enable = true;
    package = pkgs.master.factorio-headless;
    openFirewall = true;
    public = true;
    lan = true;
    requireUserVerification = true;
    nonBlockingSaving = true;
    game-name = "JuRaMa";
    description = "Private Gaming";
    #loadLatestSave = true;
    saveName = "Space_Race";
    extraSettingsFile = "/run/credentials/factorio.service/factorio.json";
    admins = [
      "brightphaeton"
      "honi2002"
      "maincky"
    ];
    mods-dat = ../factorio/mod-settings.dat;

    mods =
    let
      inherit (pkgs) lib;
      modDir = ../factorio/factorio-mods;
      modList = lib.pipe modDir [
        builtins.readDir
        (lib.filterAttrs (k: v: v == "regular"))
        (lib.mapAttrsToList (k: v: k))
        (builtins.filter (lib.hasSuffix ".zip"))
      ];
      modToDrv = modFileName:
        pkgs.runCommand "copy-factorio-mods" {} ''
          mkdir $out
          cp ${modDir + "/${modFileName}"} "$out/${(builtins.replaceStrings ["=20"] [ " " ] modFileName)}"
        ''
        // { deps = []; };
    in
      builtins.map modToDrv modList;
  };
  systemd.services.factorio.serviceConfig = {
    LoadCredential="factorio.json:${config.sops.templates.factorio.path}";
  };
}
