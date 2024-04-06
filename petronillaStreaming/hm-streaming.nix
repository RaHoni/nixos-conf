{ ... }:
{
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "select";
      colorScheme = "BreezeDark";
    };
    kwin = {
      titlebarButtons.left = [ "on-all-desktops" "keep-above-windows" ];
    };
    configFile = {
      "kwinrulesrc"."163954f6-f587-4a17-a257-2e25b144dda0" = {
        "Description".value = "Window settings for Windowed Projector (Source) - SecondaryCam";
        "noborder".value = true;
        "noborderrule".value = 2;
        "position".value = "1920,433";
        "positionrule".value = 2;
        "size".value = "770,433";
        "sizerule".value = 2;
        "title".value = "Windowed Projector (Source) - SecondaryCam";
        "titlematch".value = 1;
        "types".value = 1;
        "wmclass".value = "obs obs";
        "wmclasscomplete".value = true;
        "wmclassmatch".value = 1;
      };
      "kwinrulesrc"."327ae093-3801-4d67-ba60-fd7d9d8898d1" = {
        "Description".value = "Settings for firefox";
        "position".value = "1000,0";
        "positionrule".value = 2;
        "size".value = "920,1035";
        "sizerule".value = 2;
        "windowrole".value = "browser";
        "wmclass".value = "firefox";
        "wmclassmatch".value = 1;
        "count".value = 5;
        "rules".value = "eaa13f46-1681-44e9-abe8-36c663450f8a,327ae093-3801-4d67-ba60-fd7d9d8898d1,163954f6-f587-4a17-a257-2e25b144dda0,ae9ffa18-b807-404e-9ca1-872efc0bd3ef,b794f030-c10d-42e9-a95b-71ae6250ea11";
      };
      "kwinrulesrc"."ae9ffa18-b807-404e-9ca1-872efc0bd3ef" = {
        "Description".value = "Copy of Window settings for Windowed Projector (Source) - SecondaryCam";
        "noborder".value = true;
        "noborderrule".value = 2;
        "position".value = "1920,0";
        "positionrule".value = 2;
        "size".value = "770,433";
        "sizerule".value = 2;
        "title".value = "Windowed Projector (Source) - Maincam";
        "titlematch".value = 1;
        "types".value = 1;
        "wmclass".value = "obs obs";
        "wmclasscomplete".value = true;
        "wmclassmatch".value = 1;
      };
      "kwinrulesrc"."b794f030-c10d-42e9-a95b-71ae6250ea11" = {
        "Description".value = "Settings for okular okular";
        "position".value = "2690,0";
        "positionrule".value = 3;
        "size".value = "1150,1080";
        "sizerule".value = 3;
        "windowrole".value = "okular::Shell#1";
        "wmclass".value = "okular okular";
        "wmclasscomplete".value = true;
        "wmclassmatch".value = 1;
      };
      "kwinrulesrc"."eaa13f46-1681-44e9-abe8-36c663450f8a" = {
        "Description".value = "Window settings for obs";
        "above".value = true;
        "aboverule".value = 3;
        "clientmachine".value = "localhost";
        "ignoregeometry".value = true;
        "ignoregeometryrule".value = 3;
        "position".value = "0,0";
        "positionrule".value = 2;
        "size".value = "1000,1035";
        "sizerule".value = 2;
        "title".value = "Profile:";
        "titlematch".value = 2;
        "types".value = 1;
        "wmclass".value = "obs obs";
        "wmclasscomplete".value = true;
        "wmclassmatch".value = 1;
      };
    };
  };
}
