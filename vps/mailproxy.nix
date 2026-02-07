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
    143
    465 # SMTP TLS
    587 # SMTP Starttls
    993
    4190 # Sieve
  ];
}
