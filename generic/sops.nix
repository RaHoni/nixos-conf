{ config, ... }:
{
sops = {
    defaultSopsFile = ../secrets/general.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true; #generate key above if it does not exist yet (has to be added manually to .sops.yaml)
    secrets.example-key = {};
  };
}
