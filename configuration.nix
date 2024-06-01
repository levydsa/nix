{ pkgs, inputs, ... }:
{
  imports =
    [
      ./hardware.nix
    ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;
      devices = [ "nodev" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  time.hardwareClockInLocalTime = true;

  hardware.sane.enable = true;
  hardware.opentabletdriver.enable = true;

  powerManagement.powertop.enable = true;

  networking = {
    hostName = "box";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 8080 ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.use-xdg-base-directories = true;

  time.timeZone = "America/Recife";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [{
        users = [ "dante" ];
        persist = true;
        keepEnv = true;
      }];
    };
  };

  users.users.dante = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "adbusers"];
  };
  users.defaultUserShell = pkgs.zsh;


  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  programs.thunar.enable = true;
  programs.xfconf.enable = true;


  programs.nix-ld.enable = true;
  programs.adb.enable = true;

  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.river = {
    enable = true;
    extraPackages = with pkgs; [
      wofi
      swaybg
      alacritty
      wl-clipboard
      inputs.eww.packages.${system}.default
    ];
  };

  sound.mediaKeys.enable = true;

  programs.git.enable = true;

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [
    "/share/zsh"
    "/share/sile"
    "/share/wayland-sessions"
  ];
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
  };

  fonts.fontconfig = {
    hinting.style = "full";
    subpixel.rgba = "rgb";
    defaultFonts = {
      serif = [ "Source Serif Pro" "Symbols Nerd Font" ];
      sansSerif = [ "Source Sans Pro" "Symbols Nerd Font" ];
      monospace = [ "Hack" "Symbols Nerd Font:pixelsize=16" ];
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    hack-font
    source-sans-pro
    source-serif-pro
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    mold

    clang
    clang-tools
    go

    bun
    nodejs_latest

    zip
    unzip

    curl
    wget
    entr
    ripgrep
    fd

    greetd.tuigreet
    cpupower-gui

    just

    inputs.flow.defaultPackage.${system}

    brightnessctl

    (graphite-gtk-theme.override {
      sizeVariants = [ "compact" ];
      tweaks = [ "black" ];
    })
  ];

  sound.enable = true;

  services = {
    cpupower-gui.enable = true;
    geoclue2.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
    upower = {
      enable = true;
      criticalPowerAction = "Hibernate";
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ epson-escpr ];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "dante";
          command = ''${pkgs.greetd.tuigreet}/bin/tuigreet -w 50 -c "dbus-launch river"'';
        };
      };
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0=75;
        STOP_CHARGE_THRESH_BAT0=80;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      };
    };
  };

  system.stateVersion = "23.11";
}

