{ pkgs, config, ... }:
{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
        network_interface = "br0";
        driver = "macvlan";
        ipam_options.driver = "dhcp";
        routes = [
          {
            destination = "100.64.0.0/16";
            gateway = config.myModules.ips.tailscale-exit.ipv4.address;
          }
        ];
      };
    };
  };

  # These files are nix implemetations of systemd files provided upstream in
  # https://github.com/containers/netavark/tree/v1.6.0/contrib/systemd/system

  systemd.sockets.netavark-dhcp-proxy = {
    description = "Netavark DHCP proxy socket";
    socketConfig = {

      SocketGroup = "podman";
      ListenStream = "%t/podman/nv-proxy.sock";
      SocketMode = "0660";
    };

    wantedBy = [ "sockets.target" ];
  };

  systemd.services.netavark-dhcp-proxy = {
    description = "Netavark DHCP proxy service";

    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.netavark}/bin/netavark dhcp-proxy -a 30";
    };

    after = [ "netavark-dhcp-proxy.socket" ];
    requires = [ "netavark-dhcp-proxy.socket" ];
    startLimitIntervalSec = 0;

    wantedBy = [ "default.target" ];
  };
}
