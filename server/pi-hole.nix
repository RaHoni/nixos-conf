{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.lists) forEach flatten;
  ips = config.local.ips;
  ipv4ts = "100.110.238.97";
  ipv6ts = "fd7a:115c:a1e0::8001:da3c";
  ipv4 = ips."pi.hole".ipv4.address;
  ipv6 = ips."pi.hole".ipv6.address;
  default_data = {
    address = [ ];
    type = "block";
    enable = true;
    groups = [ 0 ];
    comment = "Added from setup";
  };
  add_adlists = data: ''
    retry -t 5 curl -X POST "http://${ipv4}:80/api/lists" -H 'accept: application/json' -H 'content-type: application/json' -d '${
      builtins.toJSON (default_data // data)
    }'
  '';
  adLists = [
    {
      address = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://raw.githubusercontent.com/0Zinc/easylists-for-pihole/master/easyprivacy.txt"
        "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
        "https://v.firebog.net/hosts/static/w3kbl.txt"
        "https://adaway.org/hosts.txt"
        "https://v.firebog.net/hosts/AdguardDNS.txt"
        "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
        "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&amp;showintro=0&amp;mimetype=plaintext"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
        "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
        "https://v.firebog.net/hosts/Prigent-Ads.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
        "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
        "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
        "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
        "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
        "https://v.firebog.net/hosts/Prigent-Crypto.txt"
        "https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt"
        "https://phishing.army/download/phishing_army_blocklist_extended.txt"
        "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
        "https://v.firebog.net/hosts/Shalla-mal.txt"
        "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
        "https://urlhaus.abuse.ch/downloads/hostfile/"
        "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
        "https://raw.githubusercontent.com/ZingyAwesome/easylists-for-pihole/master/language/german.txt"
      ];
      comment = "Old Added from Setup";
    }
    {
      address = [
        "https://raw.githubusercontent.com/notracking/hosts-blocklists/master/adblock/adblock.txt"
        "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt"
        "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt"
        "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Win10Telemetry"
        "https://raw.githubusercontent.com/wlqY8gkVb9w1Ck5MVD4lBre9nWJez8/W10TelemetryBlocklist/master/W10TelemetryBlocklist"
        "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
        "https://v.firebog.net/hosts/Easyprivacy.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
        "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/samsung"
        "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt"
        "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
        "https://raw.githubusercontent.com/AdguardTeam/cname-trackers/master/data/combined_disguised_trackers.txt"
      ];
      comment = "Tracking (Setup)";
    }
    {
      address = [
        #"https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Streaming" # Zweifelhafte Streaming anbieter
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/notserious"
        "https://raw.githubusercontent.com/Monstanner/DuckDuckGo-Fakeshops-Blocklist/main/Blockliste"
      ];
      comment = "Fakeshops und Abofallen (Setup)";
    }
    {
      address = [
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/easylist"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/spam.mails"
        "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
        "https://v.firebog.net/hosts/Easyprivacy.txt"
        "https://v.firebog.net/hosts/Easylist.txt"
        "https://v.firebog.net/hosts/Prigent-Ads.txt"
        "https://v.firebog.net/hosts/AdguardDNS.txt"
        "https://adaway.org/hosts.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt"
        "https://raw.githubusercontent.com/AdguardTeam/cname-trackers/master/data/combined_disguised_ads.txt"
      ];
      comment = "Werbung (Setup)";
    }
    {
      address = [
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/malware"
        "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/crypto"
        "https://v.firebog.net/hosts/Prigent-Malware.txt"
        "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
        "https://raw.githubusercontent.com/Spam404/lists/master/adblock-list.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
        "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
        "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADomains.txt"
        "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
        "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
        "https://urlhaus.abuse.ch/downloads/hostfile/"
        "https://raw.githubusercontent.com/AmnestyTech/investigations/master/2021-07-18_nso/domains.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tif.txt"
      ];
      comment = "Malware (Setup)";
    }
    {
      address = [
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Phishing-Angriffe"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting3"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting4"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-0"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-1-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-1-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-3-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-3-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-4"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-5-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-5-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-6"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-7-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-7-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-8-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-8-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Volks-und-Raiffeisenbank/VR-PLZ-9-Teil-3"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/BadenWuerttemberg1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/BadenWuerttemberg2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bayern1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bayern2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Berlin"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Brandenburg"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Bremen"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hamburg"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hessen1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Hessen2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/MecklenburgVorpommern"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW3"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/NRW4"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Niedersachsen1"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Niedersachsen2"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/RheinlandPfalz"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Saarland"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Sachsen"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/SachsenAnhalt"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/SchleswigHolstein"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/DomainSquatting/DE/Sparkasse/Thueringen"
        "https://raw.githubusercontent.com/namePlayer/dhl-scamlist/main/dns-blocklists/pihole-blacklist"
        "https://www.einmalzahlungzweihundert.de/bl-einmalzahlung.txt"
      ];
      comment = "Phishing & Domain-Squatting (Setup)";
    }
    {
      address = [
        "https://big.oisd.nl"
        "https://v.firebog.net/hosts/static/w3kbl.txt"
        "https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Fake-Science"
        "https://raw.githubusercontent.com/SoftCreatR/fakerando-domains/main/all.txt"
        "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/multi.txt"
        "https://raw.githubusercontent.com/elliotwutingfeng/Inversion-DNSBL-Blocklists/main/Google_hostnames_ABP.txt"
      ];
      comment = "Diverses (Setup)";
    }
  ];
  add_all_adlists = lib.strings.concatMapStrings add_adlists adLists;
  ports_for_ips =
    ips:
    flatten (
      forEach ips (ip: [
        "${ip}:53:53/udp"
        "${ip}:53:53/tcp"
        "${ip}:80:80/tcp"
      ])
    );
in
{
  services.resolved.enable = false;

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  systemd.services.pi-hole-adlists = {
    wants = [ "podman-pi-hole.service" ];
    wantedBy = [ "multi-user.target" ];
    script = add_all_adlists + ''
      podman exec -it pi-hole /usr/local/bin/pihole -g
    '';
    path = with pkgs; [
      curl
      podman
      retry
    ];
  };

  virtualisation.oci-containers.containers.pi-hole = {
    image = "docker.io/pihole/pihole:latest";
    pull = "newer";
    networks = [ "podman:mac=ce:e7:86:a2:da:13" ];
    environment = {
      TZ = "Europe/Berlin";
      FTLCONF_webserver_api_password = "";
      FTLCONF_dns_upstreams = "208.67.222.222;2620:119:35::35;1.0.0.1;2606:4700:4700::1001";
      #FTLCONF_dns_hosts = ''192.168.1.207 honermann.info;192.168.1.207 ssl-proxy''; # simple record
      #FTLCONF_dns_hostRecord = ''honermann.info,ssl-proxy,server.otlqu2p5cvqqpnid.myfritz.net,192.168.1.207''; # add ipv4, ipv6 and ptr record
      FTLCONF_dns_listeningMode = "ALL";
      FTLCONF_dns_revServers = "true,192.168.0.0/16,192.168.1.1,localdomain";
      #FTLCONF_dns_reply_host_force4 = "true"; # Use specified IP
      #FTLCONF_dns_reply_host_force6 = "true";
      #FTLCONF_dns_reply_host_IPv4 = ipv4;
      #FTLCONF_dns_reply_host_IPv6 = ipv6;
      FTLCONF_dns_dnssec = "true";
      DNSSEC = "true";
      REV_SERVER = "true";
      REV_SERVER_CIDR = "192.168.1.0/23";
      REV_SERVER_TARGET = "192.168.1.1";
      #        FTLCONF_LOCAL_IPV4 = ipv4;
    };
    volumes = [
      "etc-pihole:/etc/pihole"
    ];
  };
}
