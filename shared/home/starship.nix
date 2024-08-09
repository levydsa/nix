{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
$username[@](cyan bold)$hostname$directory$git_branch$git_status
[\$](bold green) '';

      scan_timeout = 10;

      add_newline = false;

      username = {
        style_user = "yellow bold";
        style_root = "black bold";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };

      hostname = {
        style = "blue bold";
        ssh_only = false;
        disabled = false;
      };
    };
  };
}
