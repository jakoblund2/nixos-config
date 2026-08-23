{ config, pkgs-unstable, pkgs-stable, plasma-manager, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "resume=/dev/nvme0n1p5" "resume_offset=28600320"];
  boot.kernelModules = [ "cpuid" "msr" ];
  boot.plymouth.enable = true;

  security.protectKernelImage = false; # needed for hibernation

  # Networking
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs-unstable; [
    networkmanager-openconnect
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # Hardware
  hardware.logitech.wireless.enable = true;
  hardware.uinput.enable = true;
  hardware.fw-fanctrl.enable = true;
  hardware.fw-fanctrl.config.defaultStrategy = "medium";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = false;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
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

  fonts.packages = with pkgs-unstable; [
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
  services.displayManager.sddm.enable = true;

  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pipewire.wireplumber.extraConfig.no-ucm = {
    "monitor.alsa.properties" = {
      "alsa.use-ucm" = false;
    };
  };

  # Services
  services.printing.enable = true;
  services.hardware.bolt.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };

  # Permissions
  systemd.tmpfiles.rules = [
    "Z /etc/nixos 0755 jakob users -"
    #"w /sys/devices/system/cpu/cpufreq/boost - - - - 0" # Disable CPU boost
  ];

  systemd.services.ryzenadj-thermal-limit = {
    description = "Set Ryzen thermal limit via ryzenadj";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs-unstable.ryzenadj}/bin/ryzenadj --tctl-temp=90";
    };
  };

  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.steam.enable = true;

  # nix-ld
  programs.nix-ld.enable = true;

  # zram
  #zramSwap.enable = true;

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
    SuspendState = "mem";
  };

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 34 * 1024; }  # MiB
  ];

  # AI
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-vulkan;
    environmentVariables = {
      OLLAMA_IGPU_ENABLE = "1";
    };
    loadModels = [
      "qwen2.5-coder:7b"
      "qwen2.5-coder:14b"
    ];
  };

  services.open-webui.enable = true; # http://localhost:8080/

  # User
  users.users.jakob = {
    isNormalUser = true;
    description = "jakob";
    extraGroups = [ "networkmanager" "wheel" "uinput" "docker" ];
    shell = pkgs-unstable.fish;
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
        onlyoffice-desktopeditors
        openconnect
        #parted
        python3
        qgis
        ryzenadj
        solaar
        speechd
        spotify
        tor-browser
        transmission_4-qt
        typst
        unzip
        usbutils
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
