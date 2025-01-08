{ ... }:
let
  forwardPortsToHost =
    host: proto: ports:
    builtins.map (port: {
      destination = host;
      proto = proto;
      sourcePort = port;
    }) ports;
in
{
  networking.nat.forwardPorts = forwardPortsToHost "10.100.0.3" "tcp" [
    25
    80
    143
    443
    465
    587
    993
  ];
}
