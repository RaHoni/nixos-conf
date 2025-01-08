{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../generic/wireguard.nix
    ./mailproxy.nix
  ];
  networking = {
    hostName = "vps";
    firewall.allowPing = true;
  };

  local.full = false;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [ ../generic/sshPubkeys/id_strato.pub ];
    hashedPassword = "$y$j9T$T8WEf6v2b62kafCbeV.vI/$GgcjKnF/HfyHFxDdlel5o/ziOxSPN87rBfob0SMdV0C";
  };

  myModules.servers.wireguard = {
    enable = true;
    externalInterface = "ens6";
    publicKeys = [
      "OPHqnp925fRAsBSEeSIZsuXiH7bgko/X3sEVnPOjTk4=" # raoul-framework
      "Fn5injYhXWcz4JMhla6TMBwAwqRqHtja92z9+tu8iEQ=" # Mailserver
    ];
  };

  system.stateVersion = "24.11";

}
