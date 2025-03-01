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

  environment.persistence."/permament".directories = [
    "/var/lib/postgresql"
    "/var/lib/hydra"
  ];
}
