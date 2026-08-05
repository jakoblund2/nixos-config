{ config, pkgs, plasma-manager, nixpkgs-stable, ... }:

let
  pkgsStable = import nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "ima_hash=sha256" ];
  boot.plymouth.enable = true;

  # Networking
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # Hardware
  #hardware.bluetooth.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,MediaEndpoint";
        Experimental = true;
        KernelExperimental = true;
      };
    };
  };
  hardware.logitech.wireless.enable = true;
  hardware.uinput.enable = true;
  hardware.fw-fanctrl.enable = true;
  hardware.fw-fanctrl.config.defaultStrategy = "medium";
  #hardware.firmware = [ pkgs.sof-firmware ]; # firmware for framework microphone
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.extraModprobeConfig = ''
    blacklist snd_acp_pci
    blacklist snd_pci_ps
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

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  # Optional but recommended — sets sensible defaults and fixes the
  # Chinese-vs-Japanese glyph selection issue:
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
    serif = [ "Noto Serif" "Noto Serif CJK JP" ];
    monospace = [ "Noto Sans Mono" "Noto Sans Mono CJK JP" ];
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

  # Permissions
  systemd.tmpfiles.rules = [
    "Z /etc/nixos 0755 jakob users -"
    #"w /sys/devices/system/cpu/cpufreq/boost - - - - 1" # Enable CPU boost
  ];

  systemd.services.ryzenadj-thermal-limit = {
    description = "Set Ryzen thermal limit via ryzenadj";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --tctl-temp=90";
    };
  };

  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.steam.enable = true;

  # nix-ld
  programs.nix-ld.enable = true;

  # zram
  zramSwap.enable = true;

  # AI
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables = {
      OLLAMA_IGPU_ENABLE = "1";
    };
    loadModels = [
      "llama3.2:3b"           # fast everyday chat
      "ornith:9b"             # coding
      "north-mini-code-1.0:q4_K_M" # coding
    ];
  };

  services.open-webui.enable = true; # http://localhost:8080/

  # User
  users.users.jakob = {
    isNormalUser = true;
    description = "jakob";
    extraGroups = [ "networkmanager" "wheel" "uinput" "docker" ];
    shell = pkgs.fish;
  };

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit plasma-manager; };
  home-manager.users.jakob = import ./home.nix;

  # System packages
  environment.systemPackages =
    let
      unstablePackages = with pkgs; [
        
      ];

      stablePackages = with pkgsStable; [
        #alsa-utils
        bibata-cursors
        #blender
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

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];

  system.stateVersion = "25.11";
}