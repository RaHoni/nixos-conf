# Copyright 2024 JulianFP 
{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.myModules.servers.wireguard;
  clientIPs = builtins.genList (i: [
    "10.100.0.${builtins.toString (2 + i)}/32"
    "${cfg.ipv6Base}:${builtins.toString (2 + i)}/128"
  ]) (builtins.length cfg.publicKeys);
  hostName = config.networking.hostName;
in
{
  options.myModules.servers.wireguard = {
    enable = lib.mkEnableOption "Wireguard server config with sops";
    externalInterface = lib.mkOption {
      type = lib.types.str;
      example = "eth0";
    };
    publicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
    };
    ipv6Base = lib.mkOption {
      type = lib.types.str;
      description = "The base for the ipv6 subnet /112";
      example = "2a01:239:2b9:9600::cafe";
    };
  };

  config = lib.mkIf cfg.enable {
    #load wireguard server private key
    sops.secrets."wireguard-priv-key" = {
      sopsFile = ../secrets/${hostName}/wireguard.yaml;
    };

    # enable NAT
    networking.nat = {
      enable = true;
      #enableIPv6 = true;
      externalInterface = cfg.externalInterface;
      internalInterfaces = [ "wg0" ];
    };
    networking.firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    # Enable ipv6 routing for subnet
    services.ndppd = {
      enable = true;
      proxies = {
        ${cfg.externalInterface}.rules."${cfg.ipv6Base}:0/112" = {
          method = "iface";
          interface = "wg0";
        };
      };
    };

    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [
          "10.100.0.1/24"
          "${cfg.ipv6Base}:1/112"
        ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = 51820;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterface} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.externalInterface} -j MASQUERADE
        '';

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = config.sops.secrets."wireguard-priv-key".path;

        peers = lib.lists.zipListsWith (a: b: {
          publicKey = a;
          allowedIPs = b;
        }) cfg.publicKeys clientIPs;
      };
    };
  };
}
