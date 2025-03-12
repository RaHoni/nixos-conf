{ config, pkgs, ... }:
let
  ips = config.local.ips;
  ipv4 = ips."pi.hole".ipv4;
  ipv6 = ips."pi.hole".ipv6;
in
{
  imports = [ ../generic/ips.nix ];

  services.resolved.enable = false;

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  systemd.services.pi-hole-adlists = {
    wants = [ "podman-pi-hole.service" ];
    script = ''
      curl -X POST "http://${ipv4}:80/api/lists" -H 'accept: application/json' -H 'content-type: application/json' -d '{"address":["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts","https://raw.githubusercontent.com/0Zinc/easylists-for-pihole/master/easyprivacy.txt","https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt","https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts","https://v.firebog.net/hosts/static/w3kbl.txt","https://adaway.org/hosts.txt","https://v.firebog.net/hosts/AdguardDNS.txt","https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt","https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt","https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&amp;showintro=0&amp;mimetype=plaintext","https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts","https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts","https://v.firebog.net/hosts/Prigent-Ads.txt","https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts","https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt","https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt","https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt","https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt","https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt","https://v.firebog.net/hosts/Prigent-Crypto.txt","https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt","https://phishing.army/download/phishing_army_blocklist_extended.txt","https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt","https://v.firebog.net/hosts/Shalla-mal.txt","https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt","https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts","https://urlhaus.abuse.ch/downloads/hostfile/","https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser","https://raw.githubusercontent.com/ZingyAwesome/easylists-for-pihole/master/language/german.txt"],"type":"block","comment":"Added at setup","groups":[0],"enabled":true}' 
      podman exec -it pi-hole /usr/local/bin/pihole -g
    '';
    path = with pkgs; [
      curl
      podman
    ];
  };

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
        FTLCONF_webserver_api_password = "";
        FTLCONF_dns_upstreams = "208.67.222.222;2620:119:35::35;1.0.0.1;2606:4700:4700::1001";
        #FTLCONF_dns_hosts = ''192.168.1.207 honermann.info;192.168.1.207 ssl-proxy''; # simple record
        FTLCONF_dns_hostRecord = ''honermann.info,ssl-proxy,192.168.1.207''; # add ipv4, ipv6 and ptr record
        FTLCONF_dns_listeningMode = "ALL";
        FTLCONF_dns_revServers = "true,192.168.0.0/16,192.168.1.1,localdomain";
        FTLCONF_dns_reply_host_force4 = "true"; # Use specified IP
        FTLCONF_dns_reply_host_force6 = "true";
        FTLCONF_dns_reply_host_IPv4 = ipv4;
        FTLCONF_dns_reply_host_IPv6 = ipv6;
        FTLCONF_dns_dnssec = "true";
        DNSSEC = "true";
        REV_SERVER = "true";
        REV_SERVER_CIDR = "192.168.1.0/23";
        REV_SERVER_TARGET = "192.168.1.1";
        FTLCONF_LOCAL_IPV4 = ipv4;
      };
      volumes = [
        "etc-pihole:/etc/pihole"
      ];
    };
  };
}
