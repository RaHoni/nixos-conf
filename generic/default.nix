{ config, pkgs, inputs, lib, ... }:
let
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";
  nixpkgs-unstablePath = "${base}/nixpkgs-unstable";
  nixpkgs-stablePath = "${base}/nixpkgs-stable";
in
{
  options.local.stable = lib.mkOption {
    default = true;
    type = lib.types.bool;
  };
  imports = [
    ./sops.nix
  ];
  config = {
    #system.configurationRevision = self.shortRev or self.dirtyShortRev;


    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
      optimise.automatic = true;
      registry = {
        nixpkgs.flake = inputs.nixpkgs-stable;
        nixpkgs-unstable.flake = inputs.nixpkgs;
        streamdeck.flake = inputs.streamdeck-obs;
      };
      nixPath = [
        "nixpkgs=${nixpkgsPath}"
        "nixpkgs-unstable=${nixpkgs-unstablePath}"
        "nixpkgs-stable=${nixpkgs-stablePath}"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };

    security.sudo.extraConfig = "Defaults env_keep += SSH_AUTH_SOCK";

    systemd.tmpfiles.rules = [
      "L+ ${nixpkgsPath}     - - - - ${if config.local.stable then inputs.nixpkgs-stable else inputs.nixpkgs}"
      "L+ ${nixpkgs-unstablePath} - - - - ${inputs.nixpkgs}"
      "L+ ${nixpkgs-stablePath} - - - - ${inputs.nixpkgs-stable}"
    ];

    services.xserver = {
      layout = "de";
      xkbVariant = "deadacute";
    };

    #services.btrfs.autoScrub.enable = true;

    # Enable CUPS for printing
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.gutenprint ];
    #environment.etc."channels/nixpkgs".source = nixpkgs-stable.outPath;


    users.defaultUserShell = pkgs.zsh;
    environment.shells = with pkgs; [ zsh ];

    security.pam.u2f = {
      authFile = config.sops.secrets.yubikey-auths.path;
      origin = "pam://rahoni";
      cue = true;
    };

    environment.systemPackages = with pkgs; [
      git
    ];

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
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
        customPkgs = with pkgs; [ zsh-nix-shell zsh-powerlevel10k zsh-you-should-use zsh-autosuggestions ];
        plugins = [ "git" "sudo" "nix-shell" "you-should-use" "zsh-autosuggestions" ];
        theme = "powerlevel10k/powerlevel10k";
      };
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        update-server = "nixos-rebuild switch --flake github:RaHoni/nixos-conf --refresh";
        upgrade = "nix flake update --commit-lock-file /etc/nixos";
        nixos = "cd /etc/nixos";
        sudo = "sudo "; #This allows aliases to work with sudo
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
  };
}
