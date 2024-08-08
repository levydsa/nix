{ pkgs, ... }:
{
  services = {
    nix-daemon = {
      enable = true;
      package = pkgs.nixFlakes;
    };
  };

  programs = {
    zsh.enable = true;
    git.enable = true;
  };

  environment.systemPackages = with pkgs; [ neovim ];

  homebrew = {
    enable = true;
    autoUpdate = true;
    casks = [
      "hammerspoon"
      "amethyst"
      "alfred"
      "logseq"
      "discord"
      "iina"
    ];
  };
}
