{ ... }:
{
  services.calibre-server = {
    enable = true;
    auth = {
      enable = true;
      userDb = /statefull/calibre/users.sqlite;
    };
    libraries = [ /srv/ebooks ];
  };
}
