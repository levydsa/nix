{ config, pkgs, ... }: {
  imports = [
    ../shared/home/nvim.nix
    ../shared/home/starship.nix
    ../shared/home/alacritty.nix
    ../shared/home/zsh.nix
  ];

  programs.alacritty.settings = {
      font.normal.family = "Hack Nerd Font";
      font.size = 14;
  };

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

      go
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
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      userName = "Levy A.";
      userEmail = "levyddsa@gmail.com";
    };

    home-manager.enable = true;
  };

  services.syncthing.enable = true;
}
