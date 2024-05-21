(final: prev: {
  zsh-powerlevel10k = prev.zsh-powerlevel10k.overrideAttrs {
    #    pname = "powerlevel10k-raoul";
    installPhase = ''
      install -D powerlevel10k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
      install -D powerlevel9k.zsh-theme --target-directory=$out/share/zsh/themes/powerlevel10k
      install -D config/* --target-directory=$out/share/zsh/themes/powerlevel10k/config
      install -D internal/* --target-directory=$out/share/zsh/themes/powerlevel10k/internal
      cp -R gitstatus $out/share/zsh/themes/powerlevel10k/gitstatus
    '';
  };
  zsh-nix-shell = prev.zsh-nix-shell.overrideAttrs {
    installPhase = ''
      install -D nix-shell.plugin.zsh --target-directory=$out/share/zsh/plugins/nix-shell
      install -D scripts/* --target-directory=$out/share/zsh/plugins/nix-shell/scripts
    '';
  };
  zsh-autosuggestions = prev.zsh-autosuggestions.overrideAttrs {
    installPhase = ''
      install -D zsh-autosuggestions* --target-directory $out/share/zsh/plugins/zsh-autosuggestions
    '';
  };
})
