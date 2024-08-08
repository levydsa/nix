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
    flags = [ "--update-input" "nixpkgs" "-L" ];
    dates = "daily";
    randomizedDelaySec = "45min";
  };

  boot = {
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

  networking = {
    hostName = "macvm";
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

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Recife";

  console.font = "Lat2-Terminus16";

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
  documentation.dev.enable = true;

  users = {
    users.dante = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "adbusers" "docker" ];
      hashedPassword = "$y$j9T$.a19aFz63xukXlPCKuCmX.$PEdxJv0Ow1U94JvNE6yZ61QuSqqT0F1.AaEey6rKQy8";
    };
    defaultUserShell = pkgs.zsh;
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

      NIXOS_OZONE_WL = 1;
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
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       user = "dante";
    #       command = ''${pkgs.greetd.tuigreet}/bin/tuigreet -w 50 -c "exec dbus-launch river"'';
    #     };
    #   };
    # };
  };

  system.stateVersion = "23.11";
}
