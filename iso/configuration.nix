{ config, pkgs, ... }:
{
  networking.hostName = "raspberry";
  users.users.root.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDzB0MtJkcIedlWkrf7MvG5ngSp6EJbNA6Lbq0ooUIJMw0EJIfROgb9vbG0QWgq6gd7CwOkkQSRPkuCMFPBcDF0= Proxmox"
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git

  ];
}
