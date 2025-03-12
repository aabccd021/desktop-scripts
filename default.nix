{ pkgs }:
let

  mkScript = name: runtimeInputs: pkgs.writeShellApplication {
    name = name;
    runtimeInputs = runtimeInputs;
    text = builtins.readFile "${./scripts}/${name}.sh";
  };

  scripts = {
    kill-fzf = [ pkgs.fzf pkgs.ps ];
    get-repo = [ pkgs.gh pkgs.ghq pkgs.git ];
  };
in
pkgs.lib.mapAttrs'
  (name: runtimeInputs: {
    name = name;
    value = mkScript name runtimeInputs;
  })
  scripts

