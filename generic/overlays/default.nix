(final: prev: {
  omz-powerlevel10k = prev.zsh-powerlevel10k.overrideAttrs {
    #    pname = "powerlevel10k-raoul";
    installPhase = ''
      install -D powerlevel10k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
      install -D powerlevel9k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
      install -D config/* --target-directory=$out/share/zsh/themes/powerlevel10k/config
      install -D internal/* --target-directory=$out/share/zsh/themes/powerlevel10k/internal
      cp -R gitstatus $out/share/zsh/themes/powerlevel10k/gitstatus
    '';
  };
  omz-nix-shell = prev.zsh-nix-shell.overrideAttrs {
    installPhase = ''
      install -D nix-shell.plugin.zsh --target-directory=$out/share/zsh/plugins/nix-shell
      install -D scripts/* --target-directory=$out/share/zsh/plugins/nix-shell/scripts
    '';
  };
  omz-autosuggestions = prev.zsh-autosuggestions.overrideAttrs {
    installPhase = ''
      install -D zsh-autosuggestions* --target-directory $out/share/zsh/plugins/zsh-autosuggestions
    '';
  };
  bacula = prev.bacula.overrideAttrs {
    buildInputs = prev.bacula.buildInputs ++ [ final.libmysqlclient ];
    configureFlags = [
      "--with-logdir=/var/log/bacula"
      "--with-working-dir=/var/lib/bacula"
      "--mandir=\${out}/share/man"
      "--with-sqlite3=${final.sqlite.dev}"
      "--with-mysql=${final.libmysqlclient.dev}"
      "--with-mysql-lib=${final.libmysqlclient}/lib/mariadb"
    ];
    preBuild = ''
      sed -i "/#define HAVE_ZSTD 1/d" src/config.h
    '';
    patches = [
      ./bacula.patch
    ];
  };
  pandoc-3-12 = final.stdenv.mkDerivation rec {
    pname = "pandoc";
    version = "3.1.12";
    src = final.fetchurl {
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
      sha256 = "sha256-4w0gzD+a76EXvyGD/nTPx8sEMjfVbrYycrgr92tTeZE=";
    };
    installPhase = ''
      mkdir -p $out
      cp -a * $out
    '';
  };
  signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: {
    postPatch = ''
      substituteInPlace usr/share/applications/signal-desktop.desktop \
        --replace "Exec=" 'Exec=LANGUAGE="de-DE:en-US" ' --replace "--no-sandbox" '--no-sandbox --start-in-tray'
    '';
  });
})
