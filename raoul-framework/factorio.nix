{ pkgs, config, ... }:
let 
  placeholder = config.sops.placeholder;
in
{
  sops = {
    templates.factorio.content = ''
      {
        "username" : "${placeholder.username}",
        "game-password":"${placeholder.game-password}",
        "token":"${placeholder.token}"
      }
      '';
    secrets = {
      username.sopsFile = ../secrets/ssl-proxy/factorio.yaml;
      game-password.sopsFile = ../secrets/ssl-proxy/factorio.yaml;
      token.sopsFile = ../secrets/ssl-proxy/factorio.yaml;
    };
  };
  services.factorio = {
    enable = true;
    package = pkgs.unstable.factorio-headless;
    openFirewall = true;
    public = true;
    lan = true;
    requireUserVerification = true;
    nonBlockingSaving = true;
    game-name = "JuRaMa";
    description = "Private Gaming";
    #loadLatestSave = true;
    saveName = "Julian_and_Raoul";
    extraSettingsFile = config.sops.templates.factorio.path;
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
}
