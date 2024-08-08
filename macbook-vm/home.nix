{ config, pkgs, inputs, system, ... }: {

  imports = [ inputs.ags.homeManagerModules.default ];

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

      gdb
      kdePackages.kcachegrind
      valgrind

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

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    neovim = {
      package = inputs.neovim-nightly.packages.${system}.neovim;
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        vscode-langservers-extracted
        tailwindcss-language-server
        lua-language-server
        kotlin-language-server
        typescript
        nodePackages_latest.typescript-language-server
        jdt-language-server
        nil
        htmx-lsp
        gnumake
        inputs.zls.packages.${system}.zls
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

    zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        autoload -Uz compinit
        zmodload zsh/complist
        compinit -D
        _comp_options+=(globdots)

        bindkey -v

        zstyle ':completion:*' menu select
        zstyle ':completion:*' special-dirs true

        setopt inc_append_history

        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history

        bindkey -v '^?' backward-delete-char
      '';
      shellAliases = {
        ls = "ls --color -F";
        la = "ls -lAhX --group-directories-first";
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
        dof = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      };
      historySubstringSearch.enable = true;
      history = {
        size = 10000;
        ignoreDups = true;
        path = "${config.xdg.dataHome}/zsh/history";
      };
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
