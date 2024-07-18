{ pkgs
, inputs
, lib
, ...
}: {
  imports = [
    ./hardware.nix
  ];

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "daily";
    randomizedDelaySec = "45min";
  };

  boot = {
    kernel = {
      sysctl = {
        "kernel.perf_event_paranoid" = -1;
        "kernel.kptr_restrict" = lib.mkForce 0;
      };
    };
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

  hardware = {
    sane.enable = true;
    opentabletdriver.enable = true;
  };

  powerManagement.powertop.enable = true;

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
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 2d";
    };
  };

  time.hardwareClockInLocalTime = true;
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
      extraRules = [
        {
          users = [ "dante" ];
          persist = true;
          keepEnv = true;
        }
      ];
    };
  };

  virtualisation.docker.enable = true;

  users = {
    users.dante = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "docker" ];
    };
    defaultUserShell = pkgs.zsh;
  };

  documentation.dev.enable = true;

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          output_name = "eDP-1";
          max_fps = 30;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
        };
      };
    };

    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };

    };

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
    git.enable = true;
    zsh.enable = true;
  };

  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [
      "/share/zsh"
      "/share/sile"
      "/share/wayland-sessions"
    ];
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "sway";
      XDG_CURRENT_DESKTOP = "sway";

      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";

    };

    localBinInPath = true;

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

      greetd.tuigreet
      cpupower-gui

      just

      inputs.flow.packages.${system}.default
      libnotify

      brightnessctl
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
    geoclue2.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
    udev = {
      enable = true;
      packages = [ pkgs.android-udev-rules ];
      extraRules = ''
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-10]", RUN+="${pkgs.libnotify}/bin/notify-send --urgency=critical 'Please, plug-in some power. Battery at 10%'"
        SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
      '';
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
          command = ''${pkgs.greetd.tuigreet}/bin/tuigreet -w 50 -c "exec dbus-launch river"'';
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
