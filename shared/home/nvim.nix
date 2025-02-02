{ pkgs, inputs, ... }:
{
  programs.neovim = {
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
      inputs.zls.packages.${system}.zls
      phpactor
      gopls

      gnumake
      ripgrep
    ];
  };

  home.file.".config/nvim/init.lua".source = ./nvim/init.lua;
}
