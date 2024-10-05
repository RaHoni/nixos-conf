{ ... }:
{
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
    wantedBy = ["multi-user.target"];
  };
  
  virtualisation.oci-containers.containers.pi-hole = {
    image = "pihole/pihole:latest";
    extraOptions = [ "--ip=10.88.0.2" ];
    ports = [
      "53:53"
    ];
    environment = {
      TZ= "Europe/Berlin";
      WEBPASSWORD="";
    };
    volumes = [
      "/var/pihole/etc-pihole:/etc/pihole:copy"
      "/var/pihole/etc-dnsmasq.d:/etc/dnsmasq.d:copy"
    ];
  };
}
