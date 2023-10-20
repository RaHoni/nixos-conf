{ config, ... }:
{
  imports = [ ../generic/bacula.nix ];
  services.bacula-fd = {
    director."dir.bacula" = {
      password = "oWwZjE1DOm+ex+pchPyW8ZSPBya4rXShSG6bjB/T";
    };
  };
}
