{
  nixConfig.allow-import-from-derivation = false;

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  outputs =
    { self, ... }@inputs:
    let

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

      overlay = (_: prev: import ./default.nix { pkgs = prev; });

      pkgsFor =
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfreePredicate =
            pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              "claude-code"
              "google-chrome"
            ];
        };

      treefmtEvalFor =
        system:
        inputs.treefmt-nix.lib.evalModule (pkgsFor system) {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.prettier.enable = true;
          programs.shfmt.enable = true;
          programs.shellcheck.enable = true;
          settings.formatter.shellcheck.options = [
            "-s"
            "sh"
          ];
          settings.global.excludes = [
            "*.sql"
            "LICENSE"
          ];
        };

      packagesFor =
        system:
        let
          pkgs = pkgsFor system;
          treefmtEval = treefmtEvalFor system;
          formatter = treefmtEval.config.build.wrapper;
          scripts = import ./default.nix { pkgs = pkgs; };
          devShells = {
            default = pkgs.mkShellNoCC {
              buildInputs = [ pkgs.nixd ];
            };
          };
        in
        scripts
        // devShells
        // {
          formatting = treefmtEval.config.build.check self;
          formatter = formatter;
        };

    in
    {

      packages = forAllSystems (
        system:
        let
          packages = packagesFor system;
          pkgs = pkgsFor system;
        in
        packages
        // {
          gcroot = pkgs.linkFarm "gcroot" packages;
        }
      );

      checks = forAllSystems packagesFor;
      formatter = forAllSystems (system: (treefmtEvalFor system).config.build.wrapper);
      overlays.default = overlay;
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            buildInputs = [ pkgs.nixd ];
          };
        }
      );

    };
}
