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
      inputs.flake-utils.follows = "flake-utils";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flow = {
      url = "github:levydsa/flow";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
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
      devShells.default = with pkgs; mkShell {
        nativeBuildInputs = [
          pkg-config
          zig
          tcl
          cmake
          gnumake
          clang
          jdk21
          rustPlatform.bindgenHook
          wasmtime
          kotlin
        ];
        buildInputs = [ icu.dev zlib.dev ];
      };
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
      packages.nixosConfigurations.macvm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./macvm-configuration.nix
          home-manager.nixosModules.default
          {
            home-manager = {
              extraSpecialArgs = { inherit inputs system; };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dante = import ./macvm-home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      };
    }));
}
