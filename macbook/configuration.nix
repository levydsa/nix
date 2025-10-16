{ pkgs, config, lib, ... }:
{
  nix.linux-builder.enable = true;

  system.stateVersion = 5;
  system.primaryUser = "levy";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  users.users.levy = {
    home = "/Users/levy";
    shell = pkgs.fish;
    uid = 501;
  };
  users.knownUsers = [ "levy" ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    nerd-fonts.symbols-only
    nerd-fonts.hack
  ];

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    nixd
    libiconv
    awscli2
    kubectl

    zed-editor
    nodejs

    colima
    docker
    docker-compose
  ];
  environment.systemPath = [ "/opt/homebrew/bin" ];

  ids.gids.nixbld = 30000;
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };
    brews = [
      "dnsmasq"
    ];
    casks = [
      "obs"
      "android-studio"
      "vmware-fusion"
      "utm"
      "mos"
      "discord"
      "blender"
      "ghostty@tip"
      "cursor"
      "google-drive"
      "arduino-ide"
      "logseq"
      "whatsapp"
      "spotify"
    ];
  };
}
