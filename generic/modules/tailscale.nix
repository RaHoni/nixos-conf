{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib.types)
    bool
    str
    listOf
    nullOr
    ;
  inherit (lib) mkOption mkIf optional;
  cfg = config.local.tailscale;
  formatLists = list: (builtins.concatStringsSep "," (map (t: "tag:${t}") list));

  ipv4CidrRelaxStrict = "^([0-9]{1,3}\\.){3}[0-9]{1,3}/(3[0-2]|[12]?[0-9]|0)$";
  ipv6CidrRelaxStrict =
    "^(([0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,7})"
    + "|(([0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,6})?::"
    + "([0-9A-Fa-f]{1,4}(:[0-9A-Fa-f]{1,4}){0,6})?))"
    + "/(12[0-8]|1[01][0-9]|[1-9]?[0-9]|0)$";
  invalidIpCidrs =
    ips:
    builtins.filter (
      ip:
      (builtins.match ipv4CidrRelaxStrict ip == null) && (builtins.match ipv6CidrRelaxStrict ip == null)
    ) ips;
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
        type = listOf str;
        default = [ ];
        description = "Tags die dem Host zugewiesen werden sollen";
      };
      exit-node = mkOption {
        type = bool;
        default = false;
        description = "Ob dieser client eine exit-node sein soll";
      };
      server = mkOption {
        type = bool;
        default = cfg.exit-node;
        description = "Ist dieser client ein server";
      };
      extern = mkOption {
        type = bool;
        default = false;
        description = "ist dies ein Externen Nutzer";
      };
      routes = mkOption {
        type = listOf str;
        default = [ ];
        description = "routes to advertise";
      };
      operator = mkOption {
        type = nullOr str;
        default = null;
        description = "operator who can controll tailscale without sudo";
      };
    };
  };
  config = mkIf cfg.enable rec {
    assertions = [
      {
        assertion = (invalidIpCidrs cfg.routes) == [ ];
        message = "config.local.tailscale.routes seams to contain a value which is not an ip addr with CIDR. Namely: ${builtins.concatStringsSep ", " (invalidIpCidrs cfg.routes)}";
      }
    ];
    sops = {
      secrets."${cfg.user}-auth-key".sopsFile = inputs.self + /secrets/tailscale.yaml;
    };
    local.tailscale.tags = optional cfg.server "server" ++ optional cfg.extern "extern";
    services.tailscale = {
      enable = cfg.enable;
      authKeyFile = config.sops.secrets."${cfg.user}-auth-key".path;
      openFirewall = true;
      extraUpFlags = [
        "--login-server=https://headscale.honermann.info"
      ]
      ++ optional (cfg.operator != null) "--operator=${cfg.operator}"
      ++ optional (cfg.routes != [ ]) "--advertise-routes=${formatLists cfg.routes}"
      ++ optional (cfg.tags != [ ]) "--advertise-tags=${formatLists cfg.tags}";
      extraSetFlags = mkIf cfg.exit-node [ "--advertise-exit-node" ];
      useRoutingFeatures = mkIf cfg.exit-node "both";
    };
  };
}
