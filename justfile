
switch:
	nixos-rebuild switch --flake .#

upgrade:
	nixos-rebuild switch --flake .# --upgrade
