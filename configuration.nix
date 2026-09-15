{ config, pkgs-unstable, pkgs-stable, plasma-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 3;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs-stable.linuxPackages_latest;
    consoleLogLevel = 3;
    kernelParams = [ "quiet" "splash" "udev.log_level=3" "ttm.pages_limit=6291456" "amdttm.pages_limit=6291456" "amdttm.page_pool_size=6291456" ];
    kernelModules = [ "cpuid" "msr" ];
    plymouth.enable = true;
  };

  # Networking
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs-stable; [
    networkmanager-openconnect
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 8080 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Hardware
  hardware = {
    logitech.wireless.enable = true;
    uinput.enable = true;
    fw-fanctrl.enable = true;
    fw-fanctrl.config.defaultStrategy = "medium";
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Shows battery charge of connected devices
      };
    };
  };
  };

  security.pam.services.ly.kwallet = {
    enable = true;
    package = pkgs-stable.kdePackages.kwallet-pam;
  };

  # Disable power saving on wifi module
  environment.etc."NetworkManager/conf.d/wifi-powersave.conf".text = ''
    [connection]
    wifi.powersave = 2
  '';

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

  fonts.packages = with pkgs-stable; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    jetbrains-mono
  ];

  # Optional but recommended — sets sensible defaults and fixes the
  # Chinese-vs-Japanese glyph selection issue:
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
    serif = [ "Noto Serif" "Noto Serif CJK JP" ];
    monospace = [ "JetBrains Mono" "Noto Sans Mono CJK JP" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Console & keyboard
  console.keyMap = "dk";

  services.xserver.xkb = {
    layout = "dk";
  };

  # Optimize
  nix.settings.auto-optimise-store = true;

  # Desktop environment
  services.displayManager.ly.enable = true;

  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  # Services
  services = {
    printing.enable = true;
    hardware.bolt.enable = true;
    power-profiles-daemon.enable = true;
  };

  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.steam.enable = true;

  # nix-ld
  programs.nix-ld.enable = true;

  # zram
  zramSwap.enable = true;

  # User
  users.users.jakob = {
    isNormalUser = true;
    description = "jakob";
    extraGroups = [ "networkmanager" "wheel" "uinput" "docker" ];
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
        kdePackages.oxygen
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
        llama-cpp-vulkan # for unsloth appimage
        localsend
        mission-center
        nil # for nix language
        onlyoffice-desktopeditors
        openconnect
        #parted
        python3
        qgis
        rocmPackages.rocminfo
        ryzenadj
        solaar
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
