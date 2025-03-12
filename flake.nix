{
  nixConfig.allow-import-from-derivation = false;

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };


  outputs = { self, nixpkgs, treefmt-nix }:
    let

      overlay = (_: prev: prev.callPackage ./default.nix { });

      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixpkgs-fmt.enable = true;
        programs.prettier.enable = true;
        settings.formatter.prettier.excludes = [ "secrets.yaml" ];
        programs.shfmt.enable = true;
        programs.shellcheck.enable = true;
        settings.formatter.shellcheck.options = [ "-s" "sh" ];
        settings.global.excludes = [ "*.sql" "LICENSE" ];
      };

      scripts = import ./default.nix { pkgs = pkgs; };

      packages = scripts // {
        formatting = treefmtEval.config.build.check self;
      };

    in
    {

      formatter.x86_64-linux = treefmtEval.config.build.wrapper;

      packages.x86_64-linux = packages;

      checks.x86_64-linux = packages;

      overlays.default = overlay;

    };
}
