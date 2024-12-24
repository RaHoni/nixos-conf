{ config, ... }:
let
  ips = config.local.ips;
  ipv4 = ips."pi.hole".ipv4;
  ipv6 = ips."pi.hole".ipv6;
in
{
  imports = [ ../generic/ips.nix ];
  environment.etc = {
    "pihole-adlists".source = ./adlists.list;
    "pihole-custom".source = ./custom.list;
    "dnsmasq-cnames".source = ./cnames.conf;
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
      image = "pihole/pihole:latest";
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
      };
      volumes = [
        "/var/pihole/etc-pihole:/etc/pihole:copy"
        "/var/pihole/etc-dnsmasq.d:/etc/dnsmasq.d:copy"
      ];
    };
  };
}
