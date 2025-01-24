{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [ python3 ];

    sessionVariables = with config; {
      PYTHONSTARTUP = "${xdg.configHome}/python/startup.py";
    };

    file.".config/python/startup.py".source = ./python/startup.py;
  };
}
