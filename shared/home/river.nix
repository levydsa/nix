{ pkgs, ... }:
{
  wayland.windowManager.river =
    let
      lists = pkgs.lib.lists;
      attrsets = pkgs.lib.attrsets;
      trivial = pkgs.lib.trivial;

      pow = exp: num: lists.fold (a: b: a * b) 1 (lists.replicate exp num);

      eachIndexTag = f:
        attrsets.zipAttrs
          (trivial.pipe (lists.range 1 9) [
            (map (i: { i = i; tags = pow (i - 1) 2; }))
            (map (attrsets.mapAttrs (_: toString)))
            (map f)
          ]);

      touchpad = "pointer-2-7-SynPS/2_Synaptics_TouchPad";
      trackpoint = "pointer-2-10-TPPS/2_Elan_TrackPoint";
    in
    {
      enable = true;
      extraConfig = ''
        systemctl --user import-environment PATH WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
        dbus-update-activation-environment --systemd --all
        rivertile -view-padding 5 -outer-padding 3 &
      '';
      settings = {
        background-color = "0x000000";
        border-width = 2;
        border-color-focused = "0xffffff";
        border-color-unfocused = "0x888888";
        set-repeat = "50 300";
        default-layout = "rivertile";
        spawn = [ ];
        declare-mode = [ "normal" "locked" "passthrough" ];
        keyboard-layout = "-model thinkpad br";

        map-pointer = {
          normal = {
            "Super BTN_LEFT" = "move-view";
            "Super BTN_RIGHT" = "resize-view";
            "Super BTN_MIDDLE" = "toggle-float";
          };
        };
        input = {
          "${touchpad}" = {
            natural-scroll = true;
            tap = true;
          };

          "${trackpoint}" = {
            accel-profile = "none";
          };
        };
        map = {
          normal =
            {
              "Super P" = ''spawn "wofi -I -S drun"'';

              "Super+Shift C" = "close";
              "Super+Shift E" = "exit";
              "Super+Shift Return" = "spawn alacritty";

              "Super J" = "focus-view next";
              "Super K" = "focus-view previous";

              "Super H" = ''send-layout-cmd rivertile "main-ratio -0.05"'';
              "Super L" = ''send-layout-cmd rivertile "main-ratio +0.05"'';

              "Super Return" = "zoom";
              "Super Space" = "toggle-float";
              "Super F" = "toggle-fullscreen";
            }
            // eachIndexTag ({ i, tags }: {
              "Super ${i}" = "set-focused-tags ${tags}";
              "Super+Shift ${i}" = "set-view-tags ${tags}";
            });
        };
      };
    };
}
