{ pkgs, config, ... }:
{
  programs.fzf.enable = true;
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    historySubstringSearch.enable = true;
    history = {
      size = 10000;
      ignoreDups = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    shellAliases = {
      ls = "ls --color -F";
      la = "ls -lAh";
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      dof = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
      update =
        pkgs.lib.optionals
          pkgs.stdenv.isDarwin
          "darwin-rebuild switch --flake $HOME/Documents/nix";
    };
    syntaxHighlighting.enable = true;
    plugins = [
      rec {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/${name}/${name}.plugin.zsh";
      }
      rec {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-${name}/zsh-${name}.plugin.zsh";
      }
      rec {
        name = "history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-${name}/zsh-${name}.plugin.zsh";
      }
    ];
    initExtra = ''
      autoload -Uz compinit
      zmodload zsh/complist
      compinit -D
      _comp_options+=(globdots)

      bindkey -v

      zstyle ':completion:*' menu select
      zstyle ':completion:*' special-dirs true

      setopt inc_append_history

      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      bindkey -v '^?' backward-delete-char
    '';
  };
}
