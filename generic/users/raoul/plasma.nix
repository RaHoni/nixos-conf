{ lib, osConfig, pkgs, ... }:
{
  home.packages = [ pkgs.libsForQt5.plasma-browser-integration ];
  programs.plasma = lib.mkIf osConfig.services.xserver.desktopManager.plasma5.enable {
    enable = true;
    workspace.clickItemTo = "select";
    shortcuts = {
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = "Touchpad Toggle";
      "kded5"."Show System Activity" = "Ctrl+Esc";
      "kded5"."display" = [ "Display" "Meta+P" ];
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Lock Session" = [ "Meta+L" "Screensaver" ];
      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."Edit Tiles" = "Meta+T";
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = [ "Ctrl+F10" "Launch (C)" ];
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."Invert" = "Meta+Ctrl+I";
      "kwin"."InvertWindow" = "Meta+Ctrl+U";
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."MoveMouseToCenter" = "Meta+F6";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."Overview" = "Meta+W";
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."ShowDesktopGrid" = "Meta+F8";
      "kwin"."Suspend Compositing" = "Alt+Shift+F12";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Ctrl+F1";
      "kwin"."Switch to Desktop 2" = "Ctrl+F2";
      "kwin"."Switch to Desktop 3" = "Ctrl+F3";
      "kwin"."Switch to Desktop 4" = "Ctrl+F4";
      "kwin"."Switch to Next Desktop" = "Meta+Tab";
      "kwin"."Switch to Previous Desktop" = "Meta+Shift+Tab";
      "kwin"."ToggleMouseClick" = "Meta+*";
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Backtab";
      "kwin"."Walk Through Windows of Current Application" = "Alt+`";
      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      "kwin"."Window Close" = "Alt+F4";
      "kwin"."Window Maximize" = "Meta+PgUp";
      "kwin"."Window Minimize" = "Meta+PgDown";
      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
      "kwin"."Window Quick Tile Left" = "Meta+Left";
      "kwin"."Window Quick Tile Right" = "Meta+Right";
      "kwin"."Window Quick Tile Top" = "Meta+Up";
      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
      "kwin"."view_actual_size" = "Meta+0";
      "kwin"."view_zoom_in" = [ "Meta++" "Meta+=" ];
      "kwin"."view_zoom_out" = "Meta+-";
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "org.kde.kcalc.desktop"."_launch" = "Launch (1)";
      "org.kde.konsole.desktop"."_launch" = "Ctrl+Alt+T";
      "org.kde.krunner.desktop"."RunClipboard" = "Alt+Shift+F2";
      "org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Alt+F2" "Search" ];
      "org.kde.plasma.emojier.desktop"."_launch" = "Meta+.";
      "org.kde.spectacle.desktop"."ActiveWindowScreenShot" = "Meta+Print";
      "org.kde.spectacle.desktop"."FullScreenScreenShot" = "Shift+Print";
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+Print";
      "org.kde.spectacle.desktop"."WindowUnderCursorScreenShot" = "Meta+Ctrl+Print";
      "org.kde.spectacle.desktop"."_launch" = "Print";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "plasmashell"."activate task manager entry 1" = "Meta+1";
      "plasmashell"."activate task manager entry 2" = "Meta+2";
      "plasmashell"."activate task manager entry 3" = "Meta+3";
      "plasmashell"."activate task manager entry 4" = "Meta+4";
      "plasmashell"."activate task manager entry 5" = "Meta+5";
      "plasmashell"."activate task manager entry 6" = "Meta+6";
      "plasmashell"."activate task manager entry 7" = "Meta+7";
      "plasmashell"."activate task manager entry 8" = "Meta+8";
      "plasmashell"."activate task manager entry 9" = "Meta+9";
      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
      "plasmashell"."cycle-panels" = "Meta+Alt+P";
      "plasmashell"."manage activities" = "Meta+Q";
      "plasmashell"."previous activity" = "Meta+Alt+Tab";
      "plasmashell"."repeat_action" = "Meta+Ctrl+R";
      "plasmashell"."show dashboard" = "Ctrl+F12";
      "plasmashell"."show-on-mouse-pos" = "Meta+V";
      "plasmashell"."stop current activity" = "Meta+S";
      "systemsettings.desktop"."_launch" = "Tools";
      "wacomtablet"."Map to fullscreen" = "Meta+Ctrl+F";
      "wacomtablet"."Map to screen 1" = "Meta+Ctrl+1";
      "wacomtablet"."Map to screen 2" = "Meta+Ctrl+2";
      "wacomtablet"."Next Profile" = "Meta+Ctrl+N";
      "wacomtablet"."Previous Profile" = "Meta+Ctrl+P";
      "wacomtablet"."Toggle screen map selection" = "Meta+Ctrl+M";
      "wacomtablet"."Toggle stylus mode" = "Meta+Ctrl+S";
      "wacomtablet"."Toggle touch tool" = "Meta+Ctrl+T";
    };
    configFile = {
      "baloofilerc"."General"."dbVersion" = 2;
      "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,core-dumps,lost+found";
      "baloofilerc"."General"."exclude filters version" = 8;
      "dolphinrc"."DetailsMode"."PreviewSize" = 16;
      "dolphinrc"."DetailsMode"."SidePadding" = 0;
      "dolphinrc"."General"."RememberOpenedTabs" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
      "dolphinrc"."PreviewSettings"."Plugins" = "ebookthumbnail,jpegthumbnail,windowsimagethumbnail,imagethumbnail,appimagethumbnail,kraorathumbnail,windowsexethumbnail,svgthumbnail,comicbookthumbnail,cursorthumbnail,audiothumbnail,opendocumentthumbnail,djvuthumbnail,exrthumbnail,mobithumbnail,gsthumbnail,blenderthumbnail,directorythumbnail,ffmpegthumbs,fontthumbnail,rawthumbnail";
      "kactivitymanagerdrc"."activities"."6be81689-2eca-484f-b01d-87b761c6476e" = "Standard";
      "kactivitymanagerdrc"."main"."currentActivity" = "6be81689-2eca-484f-b01d-87b761c6476e";
      "kcminputrc"."Libinput.1133.49298.Logitech G203 LIGHTSYNC Gaming Mouse"."PointerAccelerationProfile" = 1;
      "kcminputrc"."Libinput.1256.28705.inateck KB02009 Mouse"."MiddleButtonEmulation" = true;
      "kcminputrc"."Libinput.1256.28705.inateck KB02009 Mouse"."PointerAccelerationProfile" = 1;
      "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = false;
      "kcminputrc"."Tmp"."update_info" = "delete_cursor_old_default_size.upd:DeleteCursorOldDefaultSize";
      "kded5rc"."Module-browserintegrationreminder"."autoload" = false;
      "kded5rc"."Module-device_automounter"."autoload" = false;
      "kdeglobals"."DirSelect Dialog"."DirSelectDialog Size" = "850,582";
      "kdeglobals"."General"."XftHintStyle" = "hintslight";
      "kdeglobals"."General"."XftSubPixel" = "rgb";
      "kdeglobals"."General"."fixed" = "Hack Nerd Font Mono,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."font" = "NotoSans Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."menuFont" = "NotoSans Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."smallestReadableFont" = "NotoSans Nerd Font,8,-1,5,50,0,0,0,0,0";
      "kdeglobals"."General"."toolBarFont" = "NotoSans Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."KDE"."ShowDeleteCommand" = false;
      "kdeglobals"."KDE"."SingleClick" = false;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = false;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = true;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Name";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = false;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 133;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."KScreen"."ScaleFactor" = 1.5;
      "kdeglobals"."KScreen"."ScreenScaleFactors" = "eDP1=1.5;DP1=1.5;DP2=1.5;HDMI1=1.5;HDMI2=1.5;VIRTUAL1=1.5;";
      "kdeglobals"."KShortcutsDialog Settings"."Dialog Size" = "600,440";
      "kdeglobals"."PreviewSettings"."MaximumRemoteSize" = 0;
      "kdeglobals"."WM"."activeBackground" = "49,54,59";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeFont" = "NotoSans Nerd Font,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."WM"."activeForeground" = "252,252,252";
      "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      "kgammarc"."ConfigFile"."use" = "kgammarc";
      "kglobalshortcutsrc"."ActivityManager"."_k_friendly_name" = "Activity Manager";
      "kglobalshortcutsrc"."KDE Keyboard Layout Switcher"."_k_friendly_name" = "Keyboard Layout Switcher";
      "kglobalshortcutsrc"."kaccess"."_k_friendly_name" = "Accessibility";
      "kglobalshortcutsrc"."kcm_touchpad"."_k_friendly_name" = "Touchpad";
      "kglobalshortcutsrc"."kded5"."_k_friendly_name" = "KDE Daemon";
      "kglobalshortcutsrc"."khotkeys"."_k_friendly_name" = "Custom Shortcuts Service";
      "kglobalshortcutsrc"."kmix"."_k_friendly_name" = "Audio Volume";
      "kglobalshortcutsrc"."konversation"."_k_friendly_name" = "Konversation";
      "kglobalshortcutsrc"."ksmserver"."_k_friendly_name" = "Session Management";
      "kglobalshortcutsrc"."kwin"."_k_friendly_name" = "KWin";
      "kglobalshortcutsrc"."mediacontrol"."_k_friendly_name" = "Media Controller";
      "kglobalshortcutsrc"."org.kde.dolphin.desktop"."_k_friendly_name" = "Dolphin";
      "kglobalshortcutsrc"."org.kde.kcalc.desktop"."_k_friendly_name" = "KCalc";
      "kglobalshortcutsrc"."org.kde.konsole.desktop"."_k_friendly_name" = "Konsole";
      "kglobalshortcutsrc"."org.kde.krunner.desktop"."_k_friendly_name" = "KRunner";
      "kglobalshortcutsrc"."org.kde.plasma.emojier.desktop"."_k_friendly_name" = "Emoji-Auswahl";
      "kglobalshortcutsrc"."org.kde.spectacle.desktop"."_k_friendly_name" = "Spectacle";
      "kglobalshortcutsrc"."org_kde_powerdevil"."_k_friendly_name" = "Power Management";
      "kglobalshortcutsrc"."plasmashell"."_k_friendly_name" = "Plasma";
      "kglobalshortcutsrc"."systemsettings.desktop"."_k_friendly_name" = "Systemeinstellungen";
      "kglobalshortcutsrc"."wacomtablet"."_k_friendly_name" = "Wacom Tablet";
      "kiorc"."Confirmations"."ConfirmDelete" = true;
      "kiorc"."Confirmations"."ConfirmEmptyTrash" = true;
      "kiorc"."Confirmations"."ConfirmTrash" = false;
      "kiorc"."Executable scripts"."behaviourOnLaunch" = "alwaysAsk";
      "krunnerrc"."PlasmaRunnerManager"."migrated" = true;
      "kservicemenurc"."Show"."CreateK3bAudioProject" = true;
      "kservicemenurc"."Show"."CreateK3bDataProject" = true;
      "kservicemenurc"."Show"."CreateK3bVcdProject" = true;
      "kservicemenurc"."Show"."KGetDownload" = true;
      "kservicemenurc"."Show"."WriteCdImage" = true;
      "kservicemenurc"."Show"."compressfileitemaction" = true;
      "kservicemenurc"."Show"."extractfileitemaction" = true;
      "kservicemenurc"."Show"."forgetfileitemaction" = true;
      "kservicemenurc"."Show"."installFont" = true;
      "kservicemenurc"."Show"."kactivitymanagerd_fileitem_linking_plugin" = true;
      "kservicemenurc"."Show"."kdeconnectfileitemaction" = true;
      "kservicemenurc"."Show"."kio-admin" = true;
      "kservicemenurc"."Show"."kleodecryptverifyfiles" = true;
      "kservicemenurc"."Show"."kleoencryptfiles" = true;
      "kservicemenurc"."Show"."kleoencryptfolder" = true;
      "kservicemenurc"."Show"."kleoencryptsignfiles" = true;
      "kservicemenurc"."Show"."kleosignencryptfolder" = true;
      "kservicemenurc"."Show"."kleosignfilescms" = true;
      "kservicemenurc"."Show"."kleosignfilesopenpgp" = true;
      "kservicemenurc"."Show"."mountisoaction" = true;
      "kservicemenurc"."Show"."renamePDFtotitle" = true;
      "kservicemenurc"."Show"."runInKonsole" = true;
      "kservicemenurc"."Show"."setAsWallpaper" = true;
      "kservicemenurc"."Show"."sharefileitemaction" = true;
      "kservicemenurc"."Show"."slideshowfileitemaction" = true;
      "kservicemenurc"."Show"."smb2rdc" = true;
      "kservicemenurc"."Show"."tagsfileitemaction" = true;
      "kwalletrc"."Wallet"."First Use" = false;
      "kwinrc"."Desktops"."Id_1" = "deea9854-7e00-4cf7-8729-2a1707e3fd55";
      "kwinrc"."Desktops"."Id_2" = "f71943af-5e07-402d-8667-dd352c17061c";
      "kwinrc"."Desktops"."Number" = 4;
      "kwinrc"."Desktops"."Rows" = 2;
      "kwinrc"."Effect-windowview"."TouchBorderActivate" = 2;
      "kwinrc"."Effect-windowview"."TouchBorderActivateAll" = 6;
      "kwinrc"."Input"."TabletMode" = "on";
      "kwinrc"."Plugins"."kwin4_effect_dimscreenEnabled" = true;
      "kwinrc"."Tiling"."padding" = 4;
      "kwinrc"."Tiling.01384739-a9fc-5394-9987-bc6c2f3154dc"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.043b170e-62df-5bf6-877e-d8ba8334d3ee"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.1d6229da-190f-5342-84e0-4acebdecbc4f"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.42a4c0cd-fcd6-5c1f-88d9-704f2e3699c1"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.520bd3f1-ca8c-50df-8746-88deccf192e6"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.5b7a5ba4-43cc-5910-8e98-f358f9d54b43"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.6ebe3b1d-7cab-5ef1-897a-437791835b5e"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.7c350d51-0c4a-57b8-8754-d5cbeb97f422"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.82697465-77ad-5d28-9abc-61d67edb2d50"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.9d9b594f-58df-5f40-bfea-d140ce6d86e6"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.a9240c98-c9b0-5704-a4ec-b7559c209275"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.b273a341-4b0b-5a4b-81ae-fa987f7cfb5d"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.c975e56c-354b-5a94-add4-7cfa3d2a53a4"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.d74861ba-881b-57b9-b477-7f7568c4b9e2"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.e0308fcd-5570-5487-8988-f41b81bd266e"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.ec09b179-a7d1-5efb-a54c-48eb1554a955"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.f04ff9c0-cceb-5da9-b08b-ab297c761716"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.f3ce52ea-7291-5d09-9530-33850b1a4e5f"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Tiling.f8817028-f64c-532d-ba24-69b827ab1429"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
      "kwinrc"."Wayland"."InputMethod[$e]" = "/usr/share/applications/com.github.maliit.keyboard.desktop";
      "kwinrc"."Wayland"."VirtualKeyboardEnabled" = false;
      "kwinrc"."Windows"."RollOverDesktops" = true;
      "kwinrc"."Xwayland"."Scale" = 1;
      "plasma-localerc"."Formats"."LANG" = "en_GB.UTF-8";
      "plasma-localerc"."Translations"."LANGUAGE" = "en_US";
      "systemsettingsrc"."KFileDialog Settings"."detailViewIconSize" = 16;
      "systemsettingsrc"."Open-with settings"."CompletionMode" = 1;
      "systemsettingsrc"."Open-with settings"."History" = "konso";
    };
  };
}
