(
  final: prev:
  let
    lib = prev.lib;

    localVersions = builtins.fromJSON (builtins.readFile ./factorio/versions.json);
    local = localVersions."x86_64-linux".headless.stable;

    upstreamHeadless = prev.factorio-headless;

    factorioIsNewer = lib.versionOlder upstreamHeadless.version local.version;
  in
  {
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

    keepassxc-autotype = prev.keepassxc.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ final.keyutils ];
      postInstall = ''
        install -D share/linux/org.keepassxc.KeePassXC.policy --target-directory $out/share/polkit-1/actions
      '';
      doCheck = false;
      src = final.fetchFromGitHub {
        owner = "azagon63";
        repo = "keepassxc";
        rev = "5a4c6c3";
        hash = "sha256-Yh5fO7behuq3zD+yR1ujHQS9qKAalmWJigKzsOc/3CA=";
      };
    });

    snapcast = prev.snapcast.overrideAttrs (oldAttrs: rec {
      version = "0.31.0";
      src = final.fetchFromGitHub {
        owner = "badaix";
        repo = "snapcast";
        rev = "v${version}";
        hash = "sha256-LxmYsuwFCQpeoiDK4QOREIWcMIfZABT5AdKzh9reQWI=";
      };
    });

    librespot = prev.librespot.override {
      withAvahi = true;
    };

    factorio-headless =
      if factorioIsNewer then
        prev.factorio-headless.overrideAttrs (old: {
          version = local.version;
          src = prev.fetchurl {
            name = local.name;
            url = local.url;
            sha256 = local.sha256;
          };
        })
      else
        prev.factorio-headless;
  }
)
