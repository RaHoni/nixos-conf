{ config, ... }:
{
  imports = [ ../generic/bacula.nix ];
  services.bacula-fd = {
    director."dir.bacula" = {
      password = "l8HJEqyudH9Fy4JxrXs6JoD9lXgwN+vwJvkF8NJP";
    };
  };
}
