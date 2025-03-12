{ pkgs }:
let
  mkScript = name: file: runtimeInputs: pkgs.writeShellApplication {
    name = name;
    runtimeInputs = runtimeInputs;
    text = builtins.readFile file;
  };
in
{
  kill-fzf = mkScript "kill-fzf" ./kill-fzf.sh [ pkgs.fzf pkgs.ps ];
}
