{ pkgs, plasma-manager, ... }:

{
  imports = [
    ./desktops/kde.nix
    ./desktops/hyprland.nix
    ./desktops/niri.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
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
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      update = "nix flake update --flake /etc/nixos";
      garbage-collect = "sudo nix-collect-garbage -d";
    };
    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  # Cursor
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Solaar config
  xdg.configFile."solaar/config.yaml".source = ./home-files/solaar/config.yaml;
  xdg.configFile."solaar/rules.yaml".source = ./home-files/solaar/rules.yaml;
}
