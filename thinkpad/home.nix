{ config, pkgs, inputs, system, ... }: {

  imports = [
    inputs.ags.homeManagerModules.default
    ../shared/home/nvim.nix
    ../shared/home/starship.nix
    ../shared/home/alacritty.nix
    ../shared/home/zsh.nix
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
      google-chrome
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
      hledger

      swaybg
      alacritty

      python3
      zig
      rustup
      protobuf

      jdk21
      gradle
      android-studio

      gdb
      kdePackages.kcachegrind
      valgrind

      slack

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
        declare-mode = [ "normal" "locked" "passthrough" ];
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

  services.syncthing.enable = true;
}
