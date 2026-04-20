{ config, pkgs, plasma-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" ];
  boot.plymouth.enable = true;

  # Networking
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];

  # Hardware
  hardware.bluetooth.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.uinput.enable = true;
  hardware.fw-fanctrl.enable = true;
  hardware.fw-fanctrl.config.defaultStrategy = "lazy";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Unfree
  nixpkgs.config.allowUnfree = true;

  # Locale & time
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console & keyboard
  console.keyMap = "dk-latin1";

  services.xserver.xkb = {
    layout = "dk";
  };

  # Desktop environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.settings.Theme = {
    CursorTheme = "Bibata-Modern-Ice";
    CursorSize = 24;
  };
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Services
  services.printing.enable = true;
  services.hardware.bolt.enable = true;
  services.power-profiles-daemon.enable = true;
  services.boinc.enable = true; #must run boincmgr with sudo for it to work

  # Permissions
  systemd.tmpfiles.rules = [
    "Z /etc/nixos 0755 jakob users -"
  ];


  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.steam.enable = true;

  # nix-ld
  programs.nix-ld.enable = true;

  # User
  users.users.jakob = {
    isNormalUser = true;
    description = "jakob";
    extraGroups = [ "networkmanager" "wheel" "uinput" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager; };
  home-manager.users.jakob = import ./home.nix;

  # System packages (sorted)
  environment.systemPackages = with pkgs; [
    bibata-cursors
    bolt
    brightnessctl
    discord
    earlyoom
    espeak-ng
    exfatprogs
    ffmpeg
    floorp-bin
    ftb-app
    gdal
    gnome-boxes
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    imagemagick
    kdePackages.filelight
    kdePackages.partitionmanager
    kdePackages.yakuake
    localsend
    mission-center
    nil
    openconnect
    python3
    python3Packages.numpy
    python3Packages.pillow
    python3Packages.uvicorn
    qgis
    solaar
    speechd
    spotify
    sqlite
    teams-for-linux
    unzip
    usbutils
    uv
    vlc
    vscode
    waypipe
    wget
    yt-dlp
    zip
    zoom

    (pkgs.writeShellScriptBin "esa-snap" ''
      ${pkgs.steam-run}/bin/steam-run ~/esa-snap/bin/snap "$@"
    '')
  ];

  system.stateVersion = "25.11";
}
