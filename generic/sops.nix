{ config, inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../secrets/general.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true; #generate key above if it does not exist yet (has to be added manually to .sops.yaml)
      sshKeyPaths = [ ];
    };

    secrets = {
      example-key = { };
      yubikey-auths = { };
      # Setup ssh-Hostkeys from sops
      "ssh_host_ed25519_key" = {
        sopsFile = ../secrets/${config.networking.hostName}/sshd.yaml;
      };
      "ssh_host_rsa_key" = {
        sopsFile = ../secrets/${config.networking.hostName}/sshd.yaml;
      };
    };
  };
  services.openssh.hostKeys = [
    {
      path = config.sops.secrets."ssh_host_ed25519_key".path;
      type = "ed25519";
    }
    {
      path = config.sops.secrets."ssh_host_rsa_key".path;
      type = "rsa";
    }
  ];
}

