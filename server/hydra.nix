{ hydra, config, ... }:
{
  nix.settings.allowed-uris = [
    "github:"
    "gitlab:"
    "git+https://github.com/"
    "git+ssh://github.com/"
  ];
  services.hydra = {
    enable = true;
    package = hydra;
    useSubstitutes = true;
    hydraURL = "https://hydra.honermann.info";
    notificationSender = "hydra@honermann.info";
  };

  networking.firewall.allowedTCPPorts = [ config.services.hydra.port ];

  nix.buildMachines = [
    {
      hostName = "localhost";
      protocol = null;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      supportedFeatures = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
      ];
      maxJobs = 8;
    }
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  sops.secrets.binarySigKey = {
    sopsFile = ../secrets/r-desktop/hydra.yaml;
  };

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = config.sops.secrets.binarySigKey.path;
  };

  myModules.folder.folders = {
    "/var/lib/postgresql" = { };
    "/var/lib/hydra".backup = false;
  };
}
