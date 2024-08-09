{ config, ... }:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = "${config.xdg.dataHome}/zsh";
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
    '';
    shellAliases = {
      ls = "ls --color -F";
      la = "ls -lAh";
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      dof = "git --git-dir=$HOME/.dotfiles --work-tree=$HOME";
    };
    historySubstringSearch.enable = true;
    history = {
      size = 10000;
      ignoreDups = true;
      path = "${config.programs.zsh.dotDir}/history";
    };
  };
}
