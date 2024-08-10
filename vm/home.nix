{ config, pkgs, inputs, system, ... }: {

  imports = [
    inputs.ags.homeManagerModules.default
    ../shared/home/zsh.nix
    ../shared/home/nvim.nix
    ../shared/home/starship.nix
    ../shared/home/alacritty.nix
    ../shared/home/river.nix
  ];

  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "dante";
    homeDirectory = "/home/${config.home.username}";
    preferXdgDirectories = true;
    sessionVariables = with config; {
      BROWSER = "chromium";

      RUSTUP_HOME = "${xdg.dataHome}/rustup";
      CARGO_HOME = "${xdg.dataHome}/cargo";
      GOPATH = "${xdg.dataHome}/go";

      TEXMFHOME = "${xdg.dataHome}/texmf";
      TEXMFVAR = "${xdg.cacheHome}/texlive/texmf-var";
      TEXMFCONFIG = "${xdg.configHome}/texlive/texmf-config";

      JULIA_DEPOT_PATH = "${xdg.dataHome}/julia:$JULIA_DEPOT_PATH";

      # Puts '.python_history' somewhere else
      PYTHONSTARTUP = "${xdg.configHome}/python/startup.py";

      ANDROID_HOME = "${config.home.homeDirectory}/Android/Sdk";
      GRADLE_USER_HOME = "${xdg.dataHome}/gradle";

      WLR_NO_HARDWARE_CURSORS = "1";
    };

    packages = with pkgs; [
      hledger

      swaybg
      alacritty

      python3
      zig
      rustup
      protobuf

      wl-clipboard
      dunst
      slurp
      grim
      wofi
    ];

    stateVersion = "23.11";
  };

  systemd.user.services =
    let
      graphical = {
        Unit = {
          PartOf = "graphical-session.target";
          After = "graphical-session.target";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    in
    {
      ags = {
        Service = {
          Type = "exec";
          ExecStart = "${inputs.ags.packages.${system}.default}/bin/ags";
        };
      } // graphical;

      bg = {
        Service = {
          Type = "exec";
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${config.home.homeDirectory}/.local/share/wp";
        };
      } // graphical;
    };

  programs = {
    ags = {
      enable = true;
      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
        libdbusmenu-gtk3
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      userName = "Levy A.";
      userEmail = "levyddsa@gmail.com";
    };

    home-manager.enable = true;
  };

  xdg = {
    enable = true;
    systemDirs.data = [ "/run/current-system/sw/share/" ];
    userDirs = {
      createDirectories = true;
      desktop = null;
      templates = null;
      publicShare = null;
      documents = "${config.home.homeDirectory}/doc";
      download = "${config.home.homeDirectory}/dl";
      pictures = "${config.home.homeDirectory}/pic";
      music = "${config.home.homeDirectory}/mu";
    };
  };

  dconf = {
    enable = true;
    settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  qt = {
    enable = true;
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };

  gtk = {
    enable = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      size = 24;
      name = "DMZ-Black";
    };
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };
  };
}
