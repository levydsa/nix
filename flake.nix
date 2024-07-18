{
  description = "nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-workaround = {
      url = "github:levydsa/zen-workaround.nix/fix-flake";
    };

    zls = {
      url = "github:zigtools/zls?ref=0.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags.url = "github:Aylur/ags";
    flow.url = "github:levydsa/flow";
  };
  outputs =
    { self, flake-utils, home-manager, nixpkgs, zen-workaround, ... } @ inputs:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      formatter = pkgs.nixpkgs-fmt;
      packages.nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.default
          zen-workaround.nixosModules.default
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs system; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dante = import ./home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    }))
    // { };
}
