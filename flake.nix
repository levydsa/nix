{
  description = "nixos config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, flake-utils, home-manager, nixpkgs, darwin, ... } @ inputs:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      home = {
        extraSpecialArgs = { inherit inputs system; };
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
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

      packages = {
        darwinConfigurations.macbook = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./macbook/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
        nixosConfigurations = {
          box = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./thinkpad/configuration.nix
              home-manager.nixosModules.default
              {
                home-manager = { users.dante = import ./thinkpad/home.nix; } // home;
              }
            ];
          };
          macvm = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            modules = [
              ./macbook-vm/configuration.nix
              home-manager.nixosModules.default
              {
                home-manager = { users.dante = import ./macbook-vm/home.nix; } // home;
              }
            ];
          };
        };
      };
    }));
}
