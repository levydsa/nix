{ pkgs, inputs, ... }:
{
  programs.neovim = {
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      gnumake
      ripgrep
    ];
  };

  home.file.".config/nvim/init.lua".source = ./nvim/init.lua;
}
