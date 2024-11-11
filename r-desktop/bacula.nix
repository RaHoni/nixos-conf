{ ... }:
{
  imports = [ ../generic/bacula.nix ];
  services.bacula-fd = {
    shutdownOnFinish = false;
    director."dir.bacula" = {
      password = "l8HJEqyudH9Fy4JxrXs6JoD9lXgwN+vwJvkF8NJP";
    };
  };
}
