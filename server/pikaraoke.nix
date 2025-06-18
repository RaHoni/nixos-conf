{ ... }:
{
  virtualisation.oci-containers.containers.pikaraoke = {
    image = "docker.io/vicwomg/pikaraoke:latest";
    pull = "newer";
    extraOptions = [ "--ip=10.88.0.5" ];
    cmd = [
      "-u https://karaoke.honermann.info"
      "--high-quality"
      "--disable-score"
      "--admin-password=abc"
    ];
    volumes = [ "pikaraoke-songs:/app/pikaraoke-songs" ];
  };
}
