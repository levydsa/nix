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

      ANDROID_HOME = "${xdg.dataHome}/android";
      GRADLE_USER_HOME = "${xdg.dataHome}/gradle";
    };

    packages = with pkgs; [
      weechat
      thunderbird
      keepassxc
      zathura
      webcord
      calibre
      krita
      reaper
      obsidian
      inkscape
      obs-studio
      mpv
      wifi-qr

      swaybg
      alacritty

      zig
      zig-shell-completions
      rustup
      gdb
      kdePackages.kcachegrind
      valgrind
      gradle

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
          kb_layout = "br";
          kb_model = "thinkpad";
          sensitivity = 0;
        };
        general = {
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
        decoration = {
          rounding = 3;
        };
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
              ", Print, exec, grim - | wl-copy"
              ", XF86Launch2, exec, grim -g \"$(slurp)\" - | wl-copy"
            ]
            (eachWorkspace (i: "$mod, ${i}, workspace, ${i}"))
            (eachWorkspace (i: "$mod, ${i}, movetoworkspace, ${i}"))
          ];
        windowrulev2 = [ "suppressevent maximize, class:.*" ];
      };
  };

  wayland.windowManager.river =
    let
      lists = pkgs.lib.lists;
      attrsets = pkgs.lib.attrsets;
      trivial = pkgs.lib.trivial;

      pow = exp: num: lists.fold (a: b: a * b) 1 (lists.replicate exp num);

      eachIndexTag = f:
        attrsets.zipAttrs
          (trivial.pipe (lists.range 1 9) [
            (map (i: { i = i; tags = pow (i - 1) 2; }))
            (map (attrsets.mapAttrs (_: toString)))
            (map f)
          ]);

      touchpad = "pointer-2-7-SynPS/2_Synaptics_TouchPad";
      trackpoint = "pointer-2-10-TPPS/2_Elan_TrackPoint";
    in
    {
      enable = true;
      extraConfig = ''
        systemctl --user import-environment PATH WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
        dbus-update-activation-environment --systemd --all
        rivertile -view-padding 5 -outer-padding 3 &
      '';
      settings = {
        background-color = "0x000000";
        border-width = 2;
        border-color-focused = "0xffffff";
        border-color-unfocused = "0x888888";
        set-repeat = "50 300";
        default-layout = "rivertile";
        spawn = [ ];
        declare-mode = [
          "normal"
          "locked"
          "passthrough"
        ];

        keyboard-layout = "-model thinkpad br";

        map-pointer = {
          normal = {
            "Super BTN_LEFT" = "move-view";
            "Super BTN_RIGHT" = "resize-view";
            "Super BTN_MIDDLE" = "toggle-float";
          };
        };
        input = {
          "${touchpad}" = {
            natural-scroll = true;
            tap = true;
          };

          "${trackpoint}" = {
            accel-profile = "none";
          };
        };
        map = {
          normal =
            {
              "Super P" = ''spawn "wofi -I -S drun"'';

              "Super+Shift C" = "close";
              "Super+Shift E" = "exit";
              "Super+Shift Return" = "spawn alacritty";

              "Super J" = "focus-view next";
              "Super K" = "focus-view previous";

              "Super H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
              "Super L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';

              "Super Return" = "zoom";
              "Super Space" = "toggle-float";
              "Super F" = "toggle-fullscreen";
            }
            // eachIndexTag ({ i, tags }: {
              "Super ${i}" = "set-focused-tags ${tags}";
              "Super+Shift ${i}" = "set-view-tags ${tags}";
            });
        };
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
        nodePackages.typescript-language-server
        nixd
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

    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [ "--enable-features=Vulkan" ];
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
    font = {
      name = "sans";
      size = 8;
    };
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
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  services = {
    gammastep = {
      enable = true;
      tray = true;
      provider = "geoclue2";
    };

    flameshot.enable = true;

    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };
}
