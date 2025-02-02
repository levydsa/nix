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

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    dwm = {
      url = "github:levydsa/dwm";
      flake = false;
    };

    dmenu = {
      url = "github:levydsa/dmenu";
      flake = false;
    };

    st = {
      url = "github:levydsa/st";
      flake = false;
    };
  };
  outputs =
    { self, flake-utils, home-manager, nixpkgs, darwin, mac-app-util, ... } @ inputs:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            _7zz = prev._7zz.override { useUasm = true; };
          })
        ];
      };
      common-home = {
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
          specialArgs = { inherit inputs; };
          modules = [
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            { home-manager = common-home; }
            {
              home-manager.sharedModules = [
                inputs.mac-app-util.homeManagerModules.default
              ];
            }
            { home-manager.users.levy = import ./macbook/home.nix; }
            ./macbook/configuration.nix
            ./shared/nix.nix
          ];
        };

        nixosConfigurations.box = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.default
            { home-manager = common-home; }
            { home-manager.users.dante = import ./thinkpad/home.nix; }
            ./thinkpad/configuration.nix
            ./shared/nix.nix
          ];
        };

        nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            home-manager.nixosModules.default
            { home-manager = common-home; }
            { home-manager.users.dante = import ./vm/home.nix; }
            ./vm/configuration.nix
          ];
        };
      };
    }));
}
