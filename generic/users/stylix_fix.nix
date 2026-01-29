{
  config,
  options,
  lib,
  ...
}:
{
  config =
    { }
    // (lib.optionalAttrs (builtins.hasAttr "stylix" options) {
      stylix.targets.blender.enable = false;
      stylix.targets.firefox.profileNames = lib.mkDefault [ "default" ];
    });
}
