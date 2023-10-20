{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/general.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true; #generate key above if it does not exist yet (has to be added manually to .sops.yaml)
      sshKeyPaths = [ ];
    };
    secrets.example-key = { };
    gnupg.sshKeyPaths = [ ];

  };
}

