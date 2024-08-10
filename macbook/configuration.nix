{ pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnsupportedSystem = true;
      allowUnfree = true;
    };
  };

  users.users.levy.home = "/Users/levy";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = true;
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    (nerdfonts.override { fonts = [
      "NerdFontsSymbolsOnly"
      "Hack"
    ]; })
  ];

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  homebrew = {
    enable = true;
    autoUpdate = true;
    casks = [
      "android-studio"
      "hammerspoon"
      "mac-mouse-fix"
      "eloston-chromium"
      "amethyst"
      "alfred"
      "logseq"
      "discord"
      "iina"
    ];
  };
}
