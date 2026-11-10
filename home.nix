{ pkgs-unstable, pkgs-stable, plasma-manager, ... }:

{
  imports = [
    ./desktops/kde.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs-unstable; [
    bat
    wl-clipboard  # lets Claude Code paste images (reads the clipboard via wl-paste)
  ];

  # Git
  programs.git = {
    enable = true;
    settings = {
      user.name = "jakob";
      user.email = "202007550@post.au.dk";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      prompt = "enabled";
    };
  };

  # Shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  # Solaar config
  xdg.configFile."solaar/config.yaml".source = ./home-files/solaar/config.yaml;
  xdg.configFile."solaar/rules.yaml".source = ./home-files/solaar/rules.yaml;

  # Speech Note dictation: Speech Note types text into the active window through
  # ydotoold, which can run as the user since jakob is in the uinput group.
  # The socket lives in its own directory so the Flatpak keeps seeing it across
  # daemon restarts (Flatpak binds single files by inode).
  systemd.user.services.ydotoold = {
    Unit.Description = "ydotool daemon (Speech Note dictation)";
    Service = {
      ExecStart = "${pkgs-unstable.ydotool}/bin/ydotoold --socket-path=%t/ydotool/socket";
      RuntimeDirectory = "ydotool";
      RuntimeDirectoryPreserve = true;
      Restart = "always";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Let the Speech Note Flatpak reach that socket
  xdg.dataFile."flatpak/overrides/net.mkiol.SpeechNote".text = ''
    [Context]
    filesystems=xdg-run/ydotool;

    [Environment]
    YDOTOOL_SOCKET=/run/user/1000/ydotool/socket
  '';

  # Default applications. Electron apps (e.g. Discord) open links via a generic
  # xdg-open that reads this file, not KDE's BrowserApplication setting. Without
  # an explicit https default they fall back to whatever else registers the
  # scheme (tor-browser), so pin Floorp here.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      "text/html" = "floorp.desktop";
      "application/xhtml+xml" = "floorp.desktop";
      "application/xml" = "org.kde.kate.desktop";
      "x-scheme-handler/ftb" = "ftb-app.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };
  # Apps (e.g. claude-code) rewrite this file in place, which blocks HM activation
  xdg.configFile."mimeapps.list".force = true;
}
