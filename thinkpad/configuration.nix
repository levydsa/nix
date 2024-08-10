{ pkgs
, inputs
, ...
}: {
  imports = [
    ./hardware.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
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
  };

  nixpkgs.config.allowUnfree = true;

  systemd.services = {
    systemd-udev-settle.enable = false;
    NetworkManager-wait-online.enable = false;
  };

  hardware = {
    sane.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  networking = {
    hostName = "box";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 4000 8080 ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 8000; to = 8010; }
      ];
    };
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = true;
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time = {
    hardwareClockInLocalTime = true;
    timeZone = "America/Recife";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "dante" ];
          persist = true;
          keepEnv = true;
        }
      ];
    };
    pam.services.gtklock = { };
  };

  virtualisation.docker.enable = true;
  documentation.dev.enable = true;

  users = {
    users.dante = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "docker" ];
      hashedPassword = "$y$j9T$/KahWkCG3cIDb3p/MxzBq.$zthD423/kWwaxHbqMmu474zE4FfFdDTAJxBlgIkn9pB";
    };
    defaultUserShell = pkgs.zsh;
    mutableUsers = false;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
    ];
  };

  programs = {
    thunar.enable = true;
    xfconf.enable = true;
    nix-ld.enable = true;
    adb.enable = true;
    river.enable = true;
    hyprland.enable = true;
    git.enable = true;
    zsh.enable = true;
  };

  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [
      "/share/zsh"
      "/share/wayland-sessions"
    ];

    localBinInPath = true;
    sessionVariables.NIXOS_OZONE_WL = 1;

    systemPackages = with pkgs; [
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

      cpupower-gui

      just

      inputs.flow.packages.${system}.default
      libnotify

      brightnessctl

      greetd.gtkgreet
      wacomtablet
      xf86_input_wacom
      cage
    ];
  };

  fonts = {
    fontconfig = {
      hinting.style = "full";
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = [ "Source Serif Pro" "Symbols Nerd Font" ];
        sansSerif = [ "Source Sans Pro" "Symbols Nerd Font" ];
        monospace = [ "Hack" "Symbols Nerd Font" ];
      };
    };
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      hack-font
      source-sans-pro
      source-serif-pro
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };

  services = {
    blueman.enable = true;
    upower.enable = true;
    geoclue2.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
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
          command = ''${pkgs.hyprland}/bin/hyprland'';
        };
      };
    };
    # avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    #   nssmdns6 = true;
    #   openFirewall = true;
    # };
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      };
    };
    dbus = {
      enable = true;
      implementation = "dbus";
    };
  };

  system.stateVersion = "23.11";
}
