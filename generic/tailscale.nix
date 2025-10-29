{ config, lib, ... }:
let
  inherit (lib.types)
    bool
    str
    listOf
    nullOr
    ;
  inherit (lib) mkOption mkIf optional;
  cfg = config.local.tailscale;
  formattedTags = builtins.concatStringsSep "," (map (t: "tag:${t}") cfg.tags);
in
{
  options = {
    local.tailscale = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Ob tailscale auf diesem Host eingerichtet werden soll";
      };
      user = mkOption {
        type = str;
        default = "raoul";
        description = "Unter welchem Nutzer dieser Host regestriert werden soll";
      };
      tags = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "Tags die dem Host zugewiesen werden sollen";
      };
      exit-node = mkOption {
        type = bool;
        default = false;
        description = "Ob dieser client eine exit-node sein soll";
      };
    };
  };
  config = rec {
    sops = mkIf cfg.enable {
      secrets."${cfg.user}-auth-key".sopsFile = "../secrets/tailscale.yaml";
    };
    services.tailscale = {
      enable = cfg.enable;
      authKeyFile = config.sops.secrets."${cfg.user}-auth-key".path;
      openFirewall = true;
      extraUpFlags = [
        "--login-url=headscale.honermann.info"
      ]
      ++ optional (cfg.tags != null) "--advertise-tags=${formattedTags}";
      extraSetFlags = mkIf cfg.exit-node [ "--advertise-exit-node" ];
      useRoutingFeatures = mkIf cfg.exit-node "server";
    };
  };
}
