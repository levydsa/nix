{ config, pkgs, inputs, system, ... }: {
  nixpkgs.config.allowUnfree = true;

  imports = [ inputs.mac-app-util.homeManagerModules.default ];

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
    #   thunderbird
    #   discord
    #   calibre
    #   krita
    #   obsidian
    #   inkscape
    #   obs-studio
    #   mpv
    #   hledger


    #   zig
    #   rustup
    #   protobuf

    #   jdk21
    #   gradle
    #   android-studio

      keepassxc
      python3
      alacritty
      slack
    ];

    stateVersion = "23.11";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Source Serif Pro" "Symbols Nerd Font" ];
      sansSerif = [ "Source Sans Pro" "Symbols Nerd Font" ];
      monospace = [ "Hack" "Symbols Nerd Font" ];
    };
  };

  programs = {
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

    #chromium = {
    #  enable = true;
    #  package = pkgs.ungoogled-chromium;
    #  commandLineArgs = [ "--enable-features=Vulkan" ];
    #};

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

  services.syncthing.enable = true;
}
