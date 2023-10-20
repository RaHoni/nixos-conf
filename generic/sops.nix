{ config, ... }:
{
  sops = {
    defaultSopsFile = ../secrets/general.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true; #generate key above if it does not exist yet (has to be added manually to .sops.yaml)
      sshKeyPaths = [ ];
    };
    gnupg.sshKeyPaths = [ ];
    secrets = {
      example-key = { };
      # Setup ssh-Hostkeys from sops
      "ssh_host_ed25519_key" = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        sopsFile = ../secrets/${config.networking.hostName}/sshd.yaml;
      };
      "ssh_host_rsa_key" = {
        path = "/etc/ssh/ssh_host_rsa_key";
        sopsFile = ../secrets/${config.networking.hostName}/sshd.yaml;
      };
    };
  };
}

