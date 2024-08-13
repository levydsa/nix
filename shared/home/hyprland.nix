{ pkgs, ... }:
{
  home.packages = with pkgs; [ slurp grim ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    systemd.enableXdgAutostart = true;
    settings =
      let
        lists = pkgs.lib.lists;
        trivial = pkgs.lib.trivial;
        workspaces = lists.range 1 9;
        eachWorkspace = (f: trivial.pipe workspaces [
          (map toString)
          (map f)
        ]);
      in
      {
        "$mod" = "SUPER";
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
        input = {
          kb_layout = "br";
          kb_model = "thinkpad";
          sensitivity = 0;
        };
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(ffffffaa)";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = true;
          layout = "master";

          animation = [
            "workspaces,1,3,default,fade"
            "windows,1,1,default"
          ];
        };
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        decoration = {
          rounding = 3;
        };
        bindm = [
          "$mod, mouse:272, movewindow"
        ];
        binde = [
          '', XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 2%+''
          '', XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 2%-''
          '', XF86MonBrightnessUp, exec, brightnessctl set 2%+''
          '', XF86MonBrightnessDown, exec, brightnessctl set 2%-''
        ];
        bind =
          lists.flatten [
            [
              "$mod, P, exec, wofi -I -S drun"
              "$mod SHIFT, RETURN, exec, alacritty"
              "$mod SHIFT, C, killactive,"
              "$mod SHIFT, E, exit,"

              "$mod, H, layoutmsg, mfact -0.05"
              "$mod, L, layoutmsg, mfact +0.05"
              "$mod, RETURN, layoutmsg, swapwithmaster"

              "$mod, J, cyclenext,"
              "$mod, K, cyclenext, prev"

              "$mod, SPACE, togglefloating"

              '', Print, exec, grim - | wl-copy''
              '', XF86Launch2, exec, grim -g "$(slurp)" - | wl-copy''

              '', XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle''
              '', XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle''
            ]
            (eachWorkspace (i: "$mod, ${i}, workspace, ${i}"))
            (eachWorkspace (i: "$mod SHIFT, ${i}, movetoworkspacesilent, ${i}"))
          ];
        windowrulev2 = [ "suppressevent maximize, class:.*" ];
      };
  };
}
