{ pkgs }:
let
  mkScript = name: runtimeInputs: pkgs.writeShellApplication {
    name = name;
    runtimeInputs = runtimeInputs;
    text = builtins.readFile "${./scripts}/${name}.sh";
  };
in
{
  kill-fzf = mkScript "kill-fzf" [ pkgs.fzf pkgs.ps ];
  get-repo = mkScript "get-repo" [ pkgs.gh pkgs.ghq pkgs.git ];
}
