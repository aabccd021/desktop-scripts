{ pkgs }:
let
  scripts = {
    kill-fzf = [ pkgs.fzf pkgs.ps ];
    get-repo = [ pkgs.gh pkgs.ghq ];
    git-rebase-easy = [ pkgs.fzf ];
    clipboard = [ pkgs.xclip ];
    git-branch-fetch = [ pkgs.fzf ];
    nix-store-repair = [ ];
    tl = [ pkgs.translate-shell ];
    list-desktops = [ ];
    rcp = [ pkgs.rsync ];
    rcpd = [ pkgs.rsync ];
    kdec-share = [ pkgs.libsForQt5.kdeconnect-kde ];
    cam = [ pkgs.fzf pkgs.ffmpeg-full ];
    get-my-repo = [ pkgs.gh pkgs.ghq pkgs.fzf ];
    gc-full-nix = [ ];
  };
in
pkgs.lib.mapAttrs'
  (name: runtimeInputs: {
    name = name;
    value = pkgs.writeShellApplication {
      name = name;
      runtimeInputs = runtimeInputs;
      text = builtins.readFile "${./scripts}/${name}.sh";
    };
  })
  scripts

