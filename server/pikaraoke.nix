{ ... }:
{
  virtualisation.oci-containers.containers.pikaraoke = {
    image = "docker.io/vicwomg/pikaraoke:latest";
    pull = "newer";
    networks = [ "podman:mac=e2:99:a8:5a:17:d6" ];
    cmd = [
      "-u https://karaoke.honermann.info"
      "--high-quality"
      "--disable-score"
      "--admin-password=abc"
      "--complete-transcode-before-play" # Better compability with firefox
    ];
    volumes = [ "pikaraoke-songs:/app/pikaraoke-songs" ];
  };
}
