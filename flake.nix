{
  description = "dde for nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deepinPkgs = import ./packages { inherit pkgs; };
        deepin = flake-utils.lib.flattenTree deepinPkgs;
      in
      rec {
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "deepin-meta";
          buildInputs = nixpkgs.lib.attrsets.attrValues deepin;
        };
        packages = deepin;
        devShells = builtins.mapAttrs (
          name: value: 
            pkgs.mkShell {
              nativeBuildInputs = deepin.${name}.nativeBuildInputs;
              buildInputs = deepin.${name}.buildInputs ++ deepin.${name}.propagatedBuildInputs;
           }
        ) deepin;
      }
    ) // {
      overlays.default = final: prev: {
        deepin = (import ./packages { pkgs = prev.pkgs; });
      };
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          xcfg = config.services.xserver;
          cfg = xcfg.desktopManager.deepin;
        in
        {
          options = {
            services.xserver.desktopManager.deepin.enable = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Deepin desktop manager";
            };

            services.deepin.dde-daemon = {
              enable = mkEnableOption "dde daemon";
            };
            ## TODO: deepin-anything
          };

          config = mkMerge [

            ### TODO
            (mkIf cfg.enable {
              services.xserver.displayManager.sessionPackages = [ pkgs.deepin.core ];
              services.xserver.displayManager.lightdm.theme = mkDefault "deepin";
              services.accounts-daemon.enable = true;

              environment.pathsToLink = [ "/share" ];
              environment.systemPackages =
                let
                  deepinPkgs = with pkgs.deepin; [
                    calculator
                  ];
                in deepinPkgs;
            })

            (mkIf config.services.deepin.dde-daemon.enable {
              environment.systemPackages = [ pkgs.deepin.dde-daemon ];
              systemd.packages = [ pkgs.deepin.dde-daemon ];
            })
          ];
      };
    };
}
