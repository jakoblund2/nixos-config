{ pkgs-unstable, pkgs-stable, plasma-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./microphone.nix
  ];

  # Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 3;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs-stable.linuxPackages_latest;
    consoleLogLevel = 3;
    kernelParams = [ "quiet" "splash" "udev.log_level=3" "ttm.pages_limit=6291456" "amdttm.pages_limit=6291456" "amdttm.page_pool_size=6291456" "resume_offset=117743616" ];
    kernelModules = [ "cpuid" "msr" ];
    plymouth.enable = true;
    resumeDevice = "/dev/disk/by-uuid/64d7254e-b7d2-4155-9be8-7508c24c74a8";
  };

  # Swap & sleep
  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024; # MiB, at least your RAM
  }];
  systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";

  # Networking
  networking = {
    hostName = "framework";
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    networkmanager.enable = true;
    networkmanager.plugins = with pkgs-stable; [ networkmanager-openconnect ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 8080 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  # Hardware
  hardware = {
    logitech.wireless = { enable = true; enableGraphical = true; };  # installs solaar
    uinput.enable = true;
    fw-fanctrl.enable = true;
    fw-fanctrl.config.defaultStrategy = "medium";
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;  # shows battery charge of connected devices
    };
    amdgpu.opencl.enable = true;
    graphics = { enable = true; extraPackages = [ pkgs-stable.rocmPackages.clr.icd ]; };
  };

  security.pam.services.ly.kwallet = {
    enable = true;
    package = pkgs-stable.kdePackages.kwallet-pam;
  };

  # Locale, time & keyboard
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
  console.keyMap = "dk";

  # Fonts
  fonts = {
    packages = with pkgs-stable; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
      serif = [ "Noto Serif" "Noto Serif CJK JP" ];
      monospace = [ "JetBrains Mono" "Noto Sans Mono CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Services
  services = {
    displayManager.ly.enable = true;
    desktopManager.plasma6.enable = true;
    xserver.xkb.layout = "dk";
    printing.enable = true;
    hardware.bolt.enable = true;
    languagetool.enable = true;
    usbmuxd.enable = true;
    logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
    flatpak.enable = true;
  };

  programs = {
    appimage.enable = true;
    appimage.binfmt = true;
    fish.enable = true;
    steam.enable = true;
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs-stable; [ stdenv.cc.cc.lib zlib libdrm numactl elfutils libGL glib libxcb libX11 libxext libsm libice wayland libxkbcommon alsa-lib ];
  };

  # Folding@home
  services.foldingathome = {
    enable = true;
    user = "Jakob";        # name shown in the stats
    # team = 236565;       # this is the default, the NixOS team
    daemonNiceLevel = 19;  # lowest priority
  };
  # GPU access for the module's DynamicUser
  systemd.services.foldingathome.serviceConfig.SupplementaryGroups = [ "video" "render" ];

  # User
  users.users.jakob = {
    isNormalUser = true;
    description = "jakob";
    extraGroups = [ "networkmanager" "wheel" "uinput" "video" "render" ];
    shell = pkgs-stable.fish;
  };

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager pkgs-unstable pkgs-stable; };
  home-manager.users.jakob = import ./home.nix;

  # System packages
  environment.systemPackages =
    let
      unstablePackages = with pkgs-unstable; [
        claude-code
        kdePackages.oxygen
        llama-cpp-vulkan
      ];

      stablePackages = with pkgs-stable; [
        bolt
        brightnessctl
        discord
        earlyoom
        espeak-ng
        #exfatprogs
        fastfetch
        ffmpeg
        floorp-bin
        freecad
        gdal
        gearlever
        #gnome-boxes
        htop
        imagemagick
        jq
        kdePackages.filelight
        kdePackages.kamoso
        kdePackages.kate
        kdePackages.kcalc
        kdePackages.kweather
        kdePackages.partitionmanager
        kdePackages.yakuake
        #krita
        libreoffice-fresh
        librepods
        localsend
        mission-center
        nil # for nix language
        onlyoffice-desktopeditors
        openconnect
        patchelf
        #parted
        python3
        qgis
        rocmPackages.rocminfo
        ryzenadj
        sl
        speechd
        spotify
        tor-browser
        transmission_4-qt
        typst
        unzip
        usbutils
        uv
        vlc
        vscode
        waypipe
        wget
        #whisperx
        yt-dlp
        zip
        zoom-us
      ];
    in
    unstablePackages ++ stablePackages;

  environment.plasma6.excludePackages = with pkgs-unstable; [
    kdePackages.discover
  ];

  system.stateVersion = "25.11";
}
