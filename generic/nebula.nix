{ config, lib, ... }:
let
  netName = "nebulaHonermann";
  hostName = "${config.networking.hostName}";
in
{
  options = {
    local.nebula.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ob Nebula auf diesem Host eingerichtet werden soll";
    };
  };
  config = rec {
    sops = lib.mkIf config.local.nebula.enable {
      secrets."nebula/${hostName}.key" = {
        mode = "0440";
        owner = "nebula-${netName}";
        group = "nebula-${netName}";
        sopsFile = ../secrets/${hostName}/nebula.yaml;
      };
      secrets."nebula/${hostName}.crt" = {
        mode = "0440";
        owner = "nebula-${netName}";
        group = "nebula-${netName}";
        sopsFile = ../secrets/${hostName}/nebula.yaml;
      };
      secrets."nebula/ca.crt" = {
        mode = "0440";
        owner = "nebula-${netName}";
        group = "nebula-${netName}";
      };
    };

    # nebula config
    services.nebula.networks."${netName}" = rec {
      enable = config.local.nebula.enable;
      listen.port = lib.mkDefault 0;
      ca = config.sops.secrets."nebula/ca.crt".path;
      key = config.sops.secrets."nebula/${hostName}.key".path;
      cert = config.sops.secrets."nebula/${hostName}.crt".path;
      lighthouses = lib.mkIf (!config.services.nebula.networks."${netName}".isLighthouse) [
        "172.20.0.1"
      ];
      staticHostMap = {
        "172.20.0.1" = [
          "lighthouse.honermann.info:123"
        ];
      };
      settings = {
        cipher = "aes";
        logging.disable_timestamp = true; # Systemd does this
        punchy = {
          punch = true;
          respond = true;
        };
        relay.relays = [ "172.20.0.1" ];
        sshd = {
          enabled = true;
          listen = "127.0.0.1:2222";
          host_key = "/var/lib/nebula/ssh_host_ed25519_key";
          authorized_users = [
            {
              user = "raoul";
              keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmMDviNCqoEH3F/Us9pgwU2oNPj8p52ktDgL02uksk8efObzEnDf6K13CpFSussedY/NfsQs+AG2xVOEe/04xr3YnGId852IKPVd9BvjvbYeqhdlunbeD5K5+yu5ERicWCYXJuRZ/L87OF4A10CFfWBQNEcNhAzHD3GCZDdwDqnd5IU8uEax5lDALP8AUbygQAguOb0RZF4jURoyXQbwxwGM0QNHWpraa5rGqXJ27ewbj17Eff6pNnmp6esrVf7XzbNjMd0yP8Gl2ge0jMApqks0ffr9NpXkCgRhOFX7Dp0u6ax0+GV/OPQ/BAMQgFsINbmQ7RE/E6KAv1MrjG++ZrdIKBxLgBuoyC8ijCuwWCiqtOJT5Xc9LN7gy3cxDnhgJBtLogDvJYtgzV96WpwrR2l+fW5kf30TJ/KhegonApbizI2hK34lAg2RXyBFfbKH5HlGE0qAAv15d8lcRd5m+lCtiNWjZvanTWL+LOEahpLW0srJC4yEVTVeLzq9656Ms= (encrypted)"
              ];
            }
          ];
        };
      };
      firewall = {
        outbound = [
          {
            host = "any";
            port = "any";
            proto = "any";
          }
        ];
        inbound = [
          {
            port = 22;
            proto = "tcp";
            host = "any";
          }
          {
            port = "any";
            proto = "icmp";
            host = "any";
          }
        ];
      };
    };
  };
}
