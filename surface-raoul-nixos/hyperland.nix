{ pkgs, ... }:

{
  # Hyprland config
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      /* -- Monitor config -- */
      # Set lockscreen background

      monitor = [
        # Internal monitor
        "eDP-1, 1800x1200, 0x0, 1.5"
        # fallback rule for random monitors
        ",preferred,auto,auto"
      ];

      /* -- Initialisation -- */
      exec-once = [
        # Execute your favorite apps at launch (waybar gets started automatically through systemd)
        "wl-paste --type text --watch cliphist store #clipboard manager: Stores only text data"
        "wl-paste --type image --watch cliphist store #clipboard manager: Stores only image data"
        "wl-paste -t text -w xclip -selection clipboard"
        "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
        "[workspace 1 silent] kwalletd6"
        "[silent] sleep 2 && nextcloud"
      ];

      env = [
        # Env vars that get set at startup
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland,x11"
        "CLUTTER_BACKEND,wayland"
        "_JAVA_AWT_WM_NONREPARENTING,1" #tiling wm fix for Java applications
        "NIXOS_OZONE_WL,1"
      ];

      /* -- Input & Bindings -- */
      input = {
        kb_layout = "de";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        tablet.output = "eDP-1";
      };

      gestures.workspace_swipe = true;

      binds.allow_workspace_cycles = true; #previous now cycles between last two used workspaces (alt+tab behaviour)

      "$mainMod" = "SUPER";
      "$screenshotDir" = "/home/julian/Pictures/Screenshots";

      #regular bindings
      bind = [
        #essential application shortcuts
        "$mainMod, E, exec, dolphin"

        #basic stuff
        "$mainMod SHIFT, Q, killactive,"
        "$mainMod SHIFT, E, exit,"
        "$mainMod SHIFT, SPACE, togglefloating,"
        "$mainMod, F, fullscreen "

        # Move focus (with mainMod + arrow keys + vim keys)
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Switch workspaces (with TAB)
        "ALT, TAB, workspace, previous"
        "$mainMod, TAB, workspace, e+1"
        "$mainMod SHIFT, TAB, workspace, e-1"
        
        # Move active window (with mainMod + SHIFT + vim keys)
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"
      ];

    };
  };
}
