{ pkgs-unstable, pkgs-stable, plasma-manager, ... }:

{
  imports = [
    ./desktops/kde.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs-unstable; [
    bat
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
    };
  };
}
