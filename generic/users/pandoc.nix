{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pandoc-3-12
    unstable.texliveFull # full latex support for pdf generation
  ];
}
