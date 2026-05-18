{ pkgs, lib, plasma-manager, ... }:

let
  enableKrohnkite = false;
  accent      = "61,212,37";
  accentLight = "118,223,101";
  accentDark  = "45,155,27";
  selectionBg = "119,224,102";
  selectionLink = "100,254,84";
in
{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  home.packages = lib.optional enableKrohnkite pkgs.kdePackages.krohnkite;

  # Plasma desktop
  programs.plasma = {
    enable = true;

    workspace.cursor = {
      theme = "Bibata-Modern-Ice";
      size = 24;
    };

    shortcuts = {
      kwin."Switch to Next Desktop" = "Meta+Tab";
      kwin."Switch to Previous Desktop" = "Meta+Shift+Tab";
      kwin."Show Desktop" = "Meta+D";
      yakuake.toggle-window-state = "F12";
    };

    configFile = {
      kdeglobals.KDE.AnimationDurationFactor = 0.7;
      kdeglobals.General.AccentColor = accent;
      kdeglobals.General.LastUsedCustomAccentColor = accent;

      "kdeglobals"."Colors:Button".BackgroundAlternate = accentLight;
      "kdeglobals"."Colors:Button".DecorationFocus = accent;
      "kdeglobals"."Colors:Button".DecorationHover = accent;
      "kdeglobals"."Colors:Button".ForegroundActive = accent;
      "kdeglobals"."Colors:Button".ForegroundLink = accentDark;

      "kdeglobals"."Colors:Complementary".DecorationFocus = accent;
      "kdeglobals"."Colors:Complementary".DecorationHover = accent;
      "kdeglobals"."Colors:Complementary".ForegroundActive = accent;
      "kdeglobals"."Colors:Complementary".ForegroundLink = accent;

      "kdeglobals"."Colors:Header".DecorationFocus = accent;
      "kdeglobals"."Colors:Header".DecorationHover = accent;
      "kdeglobals"."Colors:Header".ForegroundActive = accent;
      "kdeglobals"."Colors:Header".ForegroundLink = accentDark;

      "kdeglobals"."Colors:Selection".BackgroundAlternate = selectionBg;
      "kdeglobals"."Colors:Selection".BackgroundNormal = selectionBg;
      "kdeglobals"."Colors:Selection".DecorationFocus = accent;
      "kdeglobals"."Colors:Selection".DecorationHover = accent;
      "kdeglobals"."Colors:Selection".ForegroundActive = accent;
      "kdeglobals"."Colors:Selection".ForegroundLink = selectionLink;

      "kdeglobals"."Colors:Tooltip".DecorationFocus = accent;
      "kdeglobals"."Colors:Tooltip".DecorationHover = accent;
      "kdeglobals"."Colors:Tooltip".ForegroundActive = accent;
      "kdeglobals"."Colors:Tooltip".ForegroundLink = accentDark;

      "kdeglobals"."Colors:View".DecorationFocus = accent;
      "kdeglobals"."Colors:View".DecorationHover = accent;
      "kdeglobals"."Colors:View".ForegroundActive = accent;
      "kdeglobals"."Colors:View".ForegroundLink = accentDark;

      "kdeglobals"."Colors:Window".DecorationFocus = accent;
      "kdeglobals"."Colors:Window".DecorationHover = accent;
      "kdeglobals"."Colors:Window".ForegroundActive = accent;
      "kdeglobals"."Colors:Window".ForegroundLink = accentDark;

      kdeglobals.KDE.AutomaticLookAndFeel = true;

      "kwinrc"."NightColor".Active = false;

      ksmserverrc.General.loginMode = "emptySession";
      kwinrc.Windows.RollOverDesktops = false;
      kwinrc.Desktops.Number = 3;
      kwinrc.Desktops.Rows = 1;

      kwinrc."Effect-overview".BorderActivate = 9;

      plasma-localerc.Formats.LANG = "en_DK.UTF-8";

      yakuakerc.Dialogs.FirstRun = false;

      kcminputrc."Libinput/12972/6/FRMW0004:00 32AC:0006 Consumer Control".Enabled = true;
      kcminputrc."Libinput/12972/6/FRMW0004:00 32AC:0006 Consumer Control".NaturalScroll = true;
      kcminputrc."Libinput/2362/628/PIXA3854:00 093A:0274 Touchpad".ClickMethod = 2;
      kcminputrc."Libinput/2362/628/PIXA3854:00 093A:0274 Touchpad".NaturalScroll = true;
    };

    panels = [
      {
        location = "bottom";
        alignment = "center";
        height = 52;
        floating = true;
        hiding = "none";
        minLength = 787;
        maxLength = 1201;

        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config.General.icon = "nix-snowflake";
          }

          {
            iconTasks.launchers = [
              "applications:floorp.desktop"
              "applications:org.kde.dolphin.desktop"
            ];
          }

          { panelSpacer.expanding = true; }

          {
            name = "org.kde.plasma.pager";
            config.General = {
              displayedText = "Number";
              showApplicationIconsOnWindowOutlines = true;
              showWindowIcons = true;
              showWindowOutlines = true;
              #textDisplay = "desktopNumber";
            };
          }

          { panelSpacer.expanding = true; }

          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              hidden = [
                "org.kde.plasma.bluetooth"
                "org.kde.discover.notifier"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.devicenotifier"
                "org.kde.plasma.mediacontroller"
                "org.kde.plasma.brightness"
                "org.kde.yakuake"
                "Yakuake"
                "librepods"
                ".librepods-wrapped"
                "indicator-solaar"
              ];
            };
          }

          "org.kde.plasma.marginsseparator"

          {
            digitalClock = {
              time.format = "24h";
              date.enable = true;
              date.format = "isoDate";
            };
          }

          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };

  systemd.user.services.restore-cursor = {
    Unit.Description = "Restore cursor theme after sleep";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-cursortheme Bibata-Modern-Ice";
    };
    Install.WantedBy = [ "suspend.target" "hybrid-sleep.target" "hibernate.target" ];
  };

  # Workaround for https://github.com/nix-community/plasma-manager/issues/562:
  # AutomaticLookAndFeel resets cursor at login; re-apply Bibata after Plasma loads.
  xdg.configFile."autostart/restore-cursor.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Restore Cursor Theme
    Exec=${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-cursortheme Bibata-Modern-Ice
    Terminal=false
  '';

  # Autostart: Solaar (minimized)
  xdg.configFile."autostart/solaar.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Solaar
    Exec=${pkgs.solaar}/bin/solaar --window=hide --battery-icons=solaar
    Terminal=false
  '';

  # Autostart: Yakuake (start hidden)
  xdg.configFile."autostart/yakuake.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Yakuake
    Exec=${pkgs.kdePackages.yakuake}/bin/yakuake
    Terminal=false
  '';
}
