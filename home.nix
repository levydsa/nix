{ config, pkgs, inputs, system, ... }:
{
  targets.genericLinux.enable = true;

  nixpkgs.config.allowUnfree = true;

  home.username = "dante";
  home.homeDirectory = "/home/${config.home.username}";
  home.preferXdgDirectories = true;
  home.sessionVariables = with config; {
    XDG_CURRENT_DESKTOP = "sway";

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

  home.packages = with pkgs; [
    dunst
    rustup
    weechat
    thunderbird
    keepassxc
    zathura
    # (discord.override {
    #   withOpenASAR = true;
    #   withVencord = true;
    # })
    webcord
    libreoffice
    texliveConTeXt
    sile
    calibre
    krita
    valgrind
    kdePackages.kcachegrind
    graphviz
    reaper
    gradle
    android-studio
    android-tools
    obsidian
    inkscape
    wifi-qr
    lldb
    lua5_1
    luarocks
    obs-studio
    mpv
  ];

  programs.neovim = {
    package = inputs.neovim-nightly.packages.${system}.neovim;
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      vscode-langservers-extracted
      tailwindcss-language-server
      lua-language-server
      nil
      htmx-lsp
    ];
  };

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    tray = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    commandLineArgs = [
      "--enable-features=Vulkan"
    ];
  };

  programs.git = {
    enable = true;
    userName = "Levy A.";
    userEmail = "levyddsa@gmail.com";
  };

  xdg.enable = true;
  xdg.systemDirs.data = [ "/run/current-system/sw/share/" ];

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
    theme = {
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  programs.zsh = {
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

      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward

      export PS1="%B%F{red}[%F{yellow}%n%F{cyan}@%F{blue}%M %F{magenta}%1~%F{red}]%f%b$ "
    '';

    shellAliases = {
      update = "doas nixos-rebuild switch";
      ls = "ls --color -F";
      la = "ls -lAhX --group-directories-first";
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      dof = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      man = "man -m $HOME/.local/share/man";
    };
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };

  services = {
    flameshot = {
      enable = true;
    };
    syncthing = {
      enable = true;
      tray.enable = true;
    };
  };

  systemd.user.targets.tray = {
		Unit = {
			Description = "Home Manager System Tray";
			Requires = [ "graphical-session-pre.target" ];
		};
	};

  programs.home-manager.enable = true;

  home.stateVersion = "23.11";
}
