{ lib, config, pkgs, ... }: {
  imports = [
    ../shared/home/nvim.nix
    ../shared/home/starship.nix
    ../shared/home/alacritty.nix
    # ../shared/home/zsh.nix
    ../shared/home/ghostty.nix
  ];

  programs.alacritty.settings = {
    font.normal.family = "Hack Nerd Font";
    font.size = 14;
  };

  home = {
    sessionPath = [ "$HOME/.local/bin" ];
    username = "levy";
    homeDirectory = "/Users/${config.home.username}";
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
    };

    packages = with pkgs; [
      protobuf

      go
      zig
      rustup

      jdk21
      gradle

      discord
      keepassxc
      python3
      helix
      slack
      nodejs
      # logseq
    ];

    stateVersion = "23.11";
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # enableFishIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      userName = "Levy A.";
      userEmail = "levyddsa@gmail.com";

      extraConfig = {
        init.defaultBranch = "main";
      };
      
      ignores = [
        # Copied from: https://github.com/github/gitignore/blob/4488915eec0b3a45b5c63ead28f286819c0917de/Global/macOS.gitignore

        # General
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"

        # Icon must end with two \r
        "Icon"

        # Thumbnails
        "._*"

        # Files that might appear in the root of a volume
        ".DocumentRevisions-V100"
        ".fseventsd"
        ".Spotlight-V100"
        ".TemporaryItems"
        ".Trashes"
        ".VolumeIcon.icns"
        ".com.apple.timemachine.donotpresent"

        # Directories potentially created on remote AFP share
        ".AppleDB"
        ".AppleDesktop"
        "Network Trash Folder"
        "Temporary Items"
        ".apdisk"

        ".direnv"
      ] ++ [
      ];
    };

    gpg.enable = true;
    home-manager.enable = true;

      aerospace = {
        enable = true;
        userSettings = {
          start-at-login = true;

          mode.main.binding = {
            alt-h = "focus left";
            alt-j = "focus down";
            alt-k = "focus up";
            alt-l = "focus right";

            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";
            alt-f = "layout floating";

            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";
            alt-0 = "workspace 10";

            alt-shift-1 = "move-node-to-workspace 1";
            alt-shift-2 = "move-node-to-workspace 2";
            alt-shift-3 = "move-node-to-workspace 3";
            alt-shift-4 = "move-node-to-workspace 4";
            alt-shift-5 = "move-node-to-workspace 5";
            alt-shift-6 = "move-node-to-workspace 6";
            alt-shift-7 = "move-node-to-workspace 7";
            alt-shift-8 = "move-node-to-workspace 8";
            alt-shift-9 = "move-node-to-workspace 9";
            alt-shift-0 = "move-node-to-workspace 10";

            alt-tab = "workspace-back-and-forth";
          };

          on-window-detected = [
            {
              "if".app-id = "com.mitchellh.ghostty";
              run = [ "layout floating" ];
            }
            {
              "if".app-id = "com.apple.finder";
              run = [ "layout floating" ];
            }
          ];

        };
      };
    fish = {
      enable = true;
      shellInit = ''
        fish_vi_key_bindings
      '';
    };
  };

  programs.zsh = {
    initExtra = ''
      if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
      then
          exec fish -l
      fi
    '';
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs; [
       tmuxPlugins.cpu
       {
         plugin = tmuxPlugins.resurrect;
         extraConfig = "set -g @resurrect-strategy-nvim 'session'";
       }
       {
         plugin = tmuxPlugins.continuum;
         extraConfig = ''
           set -g @continuum-restore 'on'
           set -g @continuum-save-interval '60' # minutes
         '';
       }
    ];
    extraConfig = ''
      set-option -s escape-time 100
    '';
  };

  services.syncthing = {
    enable = true;
  };

  home.file.".npmrc".text = lib.generators.toINIWithGlobalSection {} {
    globalSection = {
      prefix = "${config.home.homeDirectory}/.npm-packages";
    };
  };
}
