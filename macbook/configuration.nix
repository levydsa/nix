{ pkgs, ... }:
{
  system.stateVersion = 5;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  services.nix-daemon.enable = true;

  users.users.levy.home = "/Users/levy";

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    nerd-fonts.symbols-only
    nerd-fonts.hack
  ];

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    nixd
    libiconv
  ];
  environment.systemPath = [ "/opt/homebrew/bin" ];

  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
    };
    casks = [
      "obs"
      "android-studio"
      "vmware-fusion"
      "utm"
      "hammerspoon"
      "mac-mouse-fix"
      "eloston-chromium"
      "discord"
      "amethyst"
      "blender"
      "ghostty"
    ];
  };
}
