{ pkgs, inputs, ... }:
{
  imports = [ ./hardware.nix ];

  virtualisation = {
    docker.enable = true;
    vmware.guest.enable = true;
  };
  hardware.graphics.enable = true;
  documentation.dev.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "vm";
    networkmanager.enable = true;
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

  users = {
    users.dante = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "video" ];
      hashedPassword = "$y$j9T$.a19aFz63xukXlPCKuCmX.$PEdxJv0Ow1U94JvNE6yZ61QuSqqT0F1.AaEey6rKQy8";
    };
    defaultUserShell = pkgs.zsh;
  };

  programs = {
    thunar.enable = true;
    nix-ld.enable = true;
    git.enable = true;
    zsh.enable = true;
  };

  environment = {
    shells = with pkgs; [ zsh ];
    pathsToLink = [
      "/share/zsh"
      "/share/wayland-sessions"
    ];

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

      libnotify

      brightnessctl
      dconf
      xclip

      (pkgs.dmenu.overrideAttrs {
        src = inputs.dmenu;
        prePatch = ''
          sed -i "s@^PREFIX = .*@PREFIX = $out@" config.mk
        '';
      })

      (pkgs.dwm.overrideAttrs {
        src = inputs.dwm;
        prePatch = ''
          sed -i "s@^PREFIX = .*@PREFIX = $out@" config.mk
        '';
      })

      (pkgs.st.overrideAttrs {
        src = inputs.st;
        prePatch = ''
          sed -i "s@^PREFIX = .*@PREFIX = $out@" config.mk
        '';
      })
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
      noto-fonts-cjk-sans
      hack-font
      source-sans-pro
      source-serif-pro
      nerd-fonts.symbols-only
    ];
  };

  services = {
    gvfs.enable = true;
    tumbler.enable = true;
    openssh.enable = true;
    udisks2.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      # displayManager.startx.enable = true;
      windowManager.dwm = {
        enable = true;
        package = pkgs.dwm.overrideAttrs {
          src = inputs.dwm;
          prePatch = ''
            sed -i 's/^PREFIX = .*/PREFIX = $out/' config.mk
          '';
        };
      };
    };
  };

  system.stateVersion = "23.11";
}
