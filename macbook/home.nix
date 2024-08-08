{ config, pkgs, inputs, ... }: {
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.mac-app-util.homeManagerModules.default
    ../shared/home/nvim.nix
  ];

  home = {
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
      hledger
      protobuf

      zig
      rustup

      jdk21
      gradle

      discord
      keepassxc
      python3
      slack
    ];

    stateVersion = "23.11";
  };

  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
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
        la = "ls -lAh";
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

    alacritty = {
      enable = true;
      settings = {
        font.size = 9;

        colors.primary = {
          background = "#080808";
          foreground = "#c6c6c6";
        };

        window = {
          opacity = 0.92;
          blur = true;
        };

        colors.normal = {
          black   = "#323437";
          red     = "#ff5454";
          green   = "#8cc85f";
          yellow  = "#e3c78a";
          blue    = "#80a0ff";
          magenta = "#cf87e8";
          cyan    = "#79dac8";
          white   = "#c6c6c6";
        };

        colors.bright = {
          black   = "#323437";
          red     = "#ff5454";
          green   = "#8cc85f";
          yellow  = "#e3c78a";
          blue    = "#80a0ff";
          magenta = "#cf87e8";
          cyan    = "#79dac8";
          white   = "#c6c6c6";
        };
      };
    };

    home-manager.enable = true;
  };

  services.syncthing.enable = true;
}
