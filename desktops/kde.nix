{ pkgs, plasma-manager, ... }:

{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

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
      kdeglobals.General.AccentColor = "61,212,37";
      kdeglobals.General.LastUsedCustomAccentColor = "61,212,37";

      ksmserverrc.General.loginMode = "emptySession";
      kwinrc.Windows.RollOverDesktops = false;
      kwinrc.Desktops.Number = 3;
      kwinrc.Desktops.Rows = 1;

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
        height = 54;
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
              textDisplay = "desktopNumber";
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

  # Autostart: Solaar (minimized)
  xdg.configFile."autostart/solaar.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Solaar
    Exec=${pkgs.solaar}/bin/solaar --window=hide
    Terminal=false
    OnlyShowIn=KDE;
    X-KDE-autostart-phase=1
  '';

  # Autostart: Yakuake (start hidden)
  xdg.configFile."autostart/yakuake.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=Yakuake
    Exec=${pkgs.writeShellScript "start-yakuake-hidden" ''
      ${pkgs.kdePackages.yakuake}/bin/yakuake &
      sleep 2
      ${pkgs.kdePackages.qttools}/bin/qdbus org.kde.yakuake /yakuake/window org.kde.yakuake.toggleWindowState || true
    ''}
    Terminal=false
    OnlyShowIn=KDE;
    X-KDE-autostart-phase=1
  '';
}
