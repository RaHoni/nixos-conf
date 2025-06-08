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
    });
}
