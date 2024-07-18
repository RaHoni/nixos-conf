{pkgs, ...}:
{
  home.packages = with pkgs; [
    pandoc
    texliveFull #full latex support for pdf generation
  ];
}
