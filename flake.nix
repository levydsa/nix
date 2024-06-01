{
  description = "nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    eww.url = "github:/elkowar/eww";
    zig.url = "github:mitchellh/zig-overlay";
    flow.url = "github:levydsa/flow";
  };
  outputs = { self, zig, home-manager, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          zig.overlays.default
        ];
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;
      nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = { inherit inputs system; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dante = import ./home.nix;
          }
        ];
      };
    };
}
