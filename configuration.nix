#1Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz") { };
  # Import the unstable channel
  unstableTarball = 
    fetchTarball 
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  
  # Create an unstable package set
  unstable = import unstableTarball { 
    config = config.nixpkgs.config;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
boot.kernelPackages = pkgs.linuxPackages_latest;
boot.kernelModules = [ "kvm-intel" "kvm-amd" "broadcom_sta" ];

boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [
    "initcall_blacklist=simpledrm_platform_driver_init"
  ];
   hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
  };
services.blueman.enable = true;
 services.xserver.videoDrivers = [ "nvidia" ]; 

 # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking = {
  hostName = "nixos"; # Define your hostname.
  wireless.iwd.enable = true;
  networkmanager.enable = true;
  networkmanager.wifi.backend = "iwd";
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  #services.gnome.core-utilities.enable = false;
 # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  programs.xwayland.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
services.xserver.excludePackages = [ pkgs.xterm ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
 programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};
 services.flatpak.enable = true;
fonts.packages = with pkgs; [
  nerdfonts
  ];
environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  fenix.minimal.toolchain
  xdg-utils

  ] ++ (with unstable; [
  vulkan-tools
  xfce.xfce4-settings
  xfce.xfwm4-themes
  xdg-terminal-exec-mkhl
  htop-vim
      
  gvfs
  nfs-utils
  ntfs3g
  unzip
  xdotool
  freetype
  haskellPackages.freetype2
  lxqt.lxqt-policykit
  eog
  yelp
  file-roller
  xfce.thunar
  xfce.thunar-volman
  xfce.thunar-archive-plugin
  bat
  neovim-unwrapped

  zlib
  bluez
  bluetuith
  #tui
  impala
  gtop
  nnn
  yazi

  networkmanagerapplet

  libgcc
  gcc
  rustup

  steam
  qbittorrent
  ffmpeg-full
  nwjs-ffmpeg-prebuilt
  popcorntime

  wget
  google-chrome
  firefox-bin
  git
  fzf
  kitty
  alacritty
  nautilus

  wayland
  wayland-utils
  swaynotificationcenter
  xdg-desktop-portal-hyprland
  hyprland
  procps
  dex
  waybar
  libappindicator
  hyprpaper
  hyprlock
  rofi-wayland

  mpv
  (python3Full.withPackages(ps: with ps; [ pyquery ]))
  jq
  killall
  wl-clipboard
  nomacs
  
  #theme
    nwg-look
    orchis-theme
    libsForQt5.full
    libsForQt5.qt5.qtwayland
    libsForQt5.qtkeychain
    libsForQt5.qtstyleplugins

    gnome-themes-extra
    bibata-cursors
    adw-gtk3
    adwaita-qt
    adwaita-qt6
    adwaita-icon-theme

  ]);
  xdg.portal.config.common.default = [ "gtk" ];
  xdg.mime.enable=true;

    xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "application/pdf" = "firefox.desktop";
    "image/jpeg" = "org.nomacs.ImageLounge.desktop";
    "image/png" = "org.nomacs.ImageLounge.desktop";
    "x-scheme-handler/terminal" = "kitty.desktop";
  };
  environment.variables.PYTHON = "${pkgs.python3}/bin/python";

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;

  };
  services.displayManager.sessionPackages = [ pkgs.hyprland ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  nix.settings.experimental-features = ["nix-command" "flakes"];
}