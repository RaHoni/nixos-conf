{ ... }:
{
  virtualisation.oci-containers.containers.warrior = {
    image = "atdr.meo.ws/archiveteam/warrior-dockerfile";
    pull = "newer";
    ports = [ "8001:8001" ];
    volumes = [ "archiveteam-warrior-projects:/home/warrior/projects" ];
  };
}
