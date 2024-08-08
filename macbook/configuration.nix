{ pkgs, ... }:
{
  services = {
    nix-daemon = {
      enable = true;
      # package = pkgs.nixFlakes;
    };
  };

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  users.users.levy.home = "/Users/levy";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = true;
    };
  };

  programs = {
    zsh.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    hack-font
    source-sans-pro
    source-serif-pro
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];

  environment.systemPackages = with pkgs; [ neovim git ];

  homebrew = {
    enable = true;
    autoUpdate = true;
    casks = [
      "hammerspoon"
      "eloston-chromium"
      "amethyst"
      "alfred"
      "logseq"
      "discord"
      "iina"
    ];
  };
}
