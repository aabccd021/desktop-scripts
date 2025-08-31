{ pkgs }:
let
  scripts = {
    kill-fzf = [
      pkgs.fzf
      pkgs.ps
    ];
    get-repo = [ pkgs.gh ];
    git-rebase-easy = [ pkgs.fzf ];
    clipboard = [
      pkgs.xclip
      pkgs.wl-clipboard
    ];
    git-branch-fetch = [ pkgs.fzf ];
    nix-store-repair = [ ];
    tl = [ pkgs.translate-shell ];
    list-desktops = [ ];
    kdec-share = [ pkgs.kdePackages.kdeconnect-kde ];
    cam = [
      pkgs.fzf
      pkgs.ffmpeg-full
    ];
    get-my-repo = [
      pkgs.gh
      pkgs.fzf
    ];
    gc-full-nix = [ ];
    screenshot-each-monitor = [
      pkgs.maim
      pkgs.jc
      pkgs.jq
    ];
    screenshot-each-monitor-wayland = [
      pkgs.grim
      pkgs.jq
      pkgs.wlr-randr
    ];
    cycle-ibus-engine = [ ];
    open-match = [ pkgs.jq ];
    ghq-gc = [ ];
    ghq-nvim-nix = [
      pkgs.fzf
      pkgs.gawk
      pkgs.moreutils
      pkgs.findutils
    ];
    ghq-nix-flake-update = [ pkgs.jq ];
    dua-nix = [ pkgs.dua ];
    npm-publish = [ pkgs.nodejs ];
    run-gh-workflow = [
      pkgs.findutils
      pkgs.yq
      pkgs.fzf
    ];
  };
in
pkgs.lib.mapAttrs' (name: runtimeInputs: {
  name = name;
  value = pkgs.writeShellApplication {
    name = name;
    runtimeInputs = runtimeInputs;
    text = builtins.readFile "${./scripts}/${name}.sh";
  };
}) scripts
