{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../generic/wireguard.nix
  ];
  networking = {
    hostName = "vps";
  };
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
    ];
  };

  system.stateVersion = "24.11";

}
