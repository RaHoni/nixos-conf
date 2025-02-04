{ config, ... }:
let
  ips = config.local.ips;
  ipv4 = ips."pi.hole".ipv4;
  ipv6 = ips."pi.hole".ipv6;
in
{
  imports = [ ../generic/ips.nix ];
  environment.etc = {
    "pihole-adlists".source = ./pihole/adlists.list;
    "pihole-custom".source = ./pihole/custom.list;
    "dnsmasq-cnames".source = ./pihole/cnames.conf;
  };
  systemd.tmpfiles.rules = [
    # Ensure the /var/pihole/etc-pihole directory exists
    "d /var/pihole/etc-pihole 0755 root root"
    "d /var/pihole/etc-dnsmasq.d 0755 root root"
  ];

  systemd.services."prepare-pihole-dir" = {
    script = ''
      cp /etc/pihole-adlists /var/pihole/etc-pihole/adlists.list
      cp /etc/pihole-custom /var/pihole/etc-pihole/custom.list
      cp /etc/dnsmasq-cnames /var/pihole/etc-dnsmasq.d/05-pihole-custom-cname.conf
    '';
    wantedBy = [ "podman-pi-hole.service" ];
  };

  services.resolved.enable = false;

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
      };
    };
    oci-containers.containers.pi-hole = {
      image = "docker.io/pihole/pihole:latest";
      labels = {
        "io.containers.autoupdate" = "registry";
      };
      ports = [
        "${ipv4}:53:53/udp"
        "${ipv4}:53:53/tcp"
        "${ipv4}:80:80/tcp"
        "[${ipv6}]:53:53/udp"
        "[${ipv6}]:53:53/tcp"
      ];
      environment = {
        TZ = "Europe/Berlin";
        WEBPASSWORD = "";
        DNSSEC = "true";
        REV_SERVER = "true";
        REV_SERVER_CIDR = "192.168.1.0/23";
        REV_SERVER_TARGET = "192.168.1.1";
        PIHOLE_DNS_ = "208.67.222.222;2620:119:35::35;1.0.0.1;2606:4700:4700::1001";
        FTLCONF_LOCAL_IPV4 = ipv4;
      };
      volumes = [
        "/var/pihole/etc-pihole:/etc/pihole:copy"
        "/var/pihole/etc-dnsmasq.d:/etc/dnsmasq.d:copy"
      ];
    };
  };
}
