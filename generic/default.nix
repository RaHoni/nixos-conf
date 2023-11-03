{ config, pkgs, ... }:
{
  imports = [
    ./sops.nix
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  security.pam.u2f = {
    authFile = config.sops.secrets.yubikey-auths.path;
    origin = "pam://rahoni";
    cue = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];

    fontconfig.defaultFonts = {
      serif = [ "MesloLGS NF Regular" ];
      sansSerif = [ "MesloLGS NF Regular" ];
      monospace = [ "MesloLGS NF Monospace" ];
    };
  };

  programs.zsh = {
    enable = true;


    #      oh-my-zsh = {
    ohMyZsh = {
      enable = true;
      customPkgs = with pkgs; [ zsh-nix-shell zsh-powerlevel10k zsh-you-should-use ];
      plugins = [ "git" "sudo" "nix-shell" "you-should-use" ];
      theme = "powerlevel10k/powerlevel10k";
    };
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      upgrade = "nix flake update --commit-lock-file /etc/nixos";
      nixos = "cd /etc/nixos";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    #   enableSSHSupport = true;
  };
  hardware.gpgSmartcards.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
}
