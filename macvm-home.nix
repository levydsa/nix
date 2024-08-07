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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    settings =
      let
        lists = pkgs.lib.lists;
        trivial = pkgs.lib.trivial;
        workspaces = lists.range 1 9;
        eachWorkspace = (f: trivial.pipe workspaces [
          (map toString)
          (map f)
        ]);
      in
      {
        "$mod" = "SUPER";
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
        input = {
          sensitivity = 0;
        };
        general = {
          monitor = ",highrr,auto,1";
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(ffffffaa)";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = true;
          layout = "master";

          animation = [
            "workspaces,1,3,default,fade"
            "windows,1,1,default"
          ];
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        decoration = {
          rounding = 3;
        };
        bindm = [
          "$mod, mouse:272, movewindow"
        ];
        binde = [
          '', XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 2%+''
          '', XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 2%-''
          '', XF86MonBrightnessUp, exec, brightnessctl set 2%+''
          '', XF86MonBrightnessDown, exec, brightnessctl set 2%-''
        ];
        bind =
          lists.flatten [
            [
              "$mod, P, exec, wofi -I -S drun"
              "$mod SHIFT, RETURN, exec, alacritty"
              "$mod SHIFT, C, killactive,"
              "$mod SHIFT, E, exit,"

              "$mod, H, layoutmsg, mfact -0.05"
              "$mod, L, layoutmsg, mfact +0.05"
              "$mod, RETURN, layoutmsg, swapwithmaster"

              "$mod, J, cyclenext,"
              "$mod, K, cyclenext, prev"

              "$mod, SPACE, togglefloating"

              '', Print, exec, grim - | wl-copy''
              '', XF86Launch2, exec, grim -g "$(slurp)" - | wl-copy''

              '', XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle''
              '', XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle''
            ]
            (eachWorkspace (i: "$mod, ${i}, workspace, ${i}"))
            (eachWorkspace (i: "$mod SHIFT, ${i}, movetoworkspacesilent, ${i}"))
          ];
        windowrulev2 = [ "suppressevent maximize, class:.*" ];
      };
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
