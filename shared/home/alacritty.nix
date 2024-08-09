{ ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      font.normal.family = "Hack Nerd Font";
      font.size = 14; 

      colors.primary = {
        background = "#080808";
        foreground = "#c6c6c6";
      };

      window = {
        opacity = 0.92;
        blur = true;
      };

      colors.normal = {
        black   = "#323437";
        red     = "#ff5454";
        green   = "#8cc85f";
        yellow  = "#e3c78a";
        blue    = "#80a0ff";
        magenta = "#cf87e8";
        cyan    = "#79dac8";
        white   = "#c6c6c6";
      };

      colors.bright = {
        black   = "#323437";
        red     = "#ff5454";
        green   = "#8cc85f";
        yellow  = "#e3c78a";
        blue    = "#80a0ff";
        magenta = "#cf87e8";
        cyan    = "#79dac8";
        white   = "#c6c6c6";
      };
    };
  };
}
