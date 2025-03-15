{
  ...
}:
{
  home.file = {
    ".p10k.zsh".source = ./p10k.zsh;

  };

  programs.zsh = {
    localVariables.YSU_HARDCORE = 1;
  };

  programs.ssh = {
    extraConfig = ''
      user raoul
    '';
  };
}
