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
  hardware.fw-fanctrl.config.defaultStrategy = "lazy";
  hardware.firmware = [ pkgs.sof-firmware ]; # firmware for framework microphone
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

  # zram
  zramSwap.enable = true;

  # AI
  #services.ollama = {
  #  enable = true;
  #  package = pkgs.ollama-vulkan;
  #  loadModels = [
  #    "llama3.2:3b"           # fast everyday chat
  #    "qwen2.5-coder:7b"      # coding daily driver, 16K+ context
  #    "qwen3:14b"             # heavy lift: reasoning, science, hard general tasks
  #  ];
  #};

  #services.open-webui.enable = true;

  # Podman (rootless, with docker CLI compatibility)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

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
    alsa-utils
    bibata-cursors
    blender
    bolt
    brightnessctl
    discord
    earlyoom
    espeak-ng
    exfatprogs
    fastfetch
    ffmpeg
    floorp-bin
    freecad
    ftb-app
    gdal
    gnome-boxes
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    htop
    imagemagick
    kdePackages.filelight
    kdePackages.kamoso
    kdePackages.kweather
    kdePackages.partitionmanager
    kdePackages.yakuake
    librepods
    localsend
    mission-center
    nil
    onlyoffice-desktopeditors
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
  ];

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];

  system.stateVersion = "25.11";
}
