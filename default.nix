{ pkgs }:
let
  scripts = {
    kill-fzf = [
      pkgs.fzf
      pkgs.procps
      pkgs.gawk
    ];
    get-repo = [
      pkgs.gh
      pkgs.gnused
      pkgs.coreutils
      pkgs.ghq
    ];
    git-rebase-easy = [
      pkgs.fzf
      pkgs.git
      pkgs.gnugrep
      pkgs.gnused
      pkgs.coreutils
    ];
    clipboard = [
      pkgs.xclip
      pkgs.wl-clipboard
    ];
    git-branch-fetch = [
      pkgs.fzf
      pkgs.git
      pkgs.gnused
      pkgs.findutils
    ];
    nix-store-repair = [
      pkgs.nix
    ];
    nix-gcroot = [
      pkgs.nix
      pkgs.coreutils
    ];
    tl = [ pkgs.translate-shell ];
    list-desktops = [
      pkgs.coreutils
      pkgs.findutils
    ];
    kdec-share = [ pkgs.kdePackages.kdeconnect-kde ];
    cam = [
      pkgs.fzf
      pkgs.ffmpeg-full
      pkgs.findutils
    ];
    get-my-repo = [
      pkgs.gh
      pkgs.fzf
      pkgs.ghq
    ];
    gc-full-nix = [
      pkgs.nix
      pkgs.doas
      pkgs.coreutils
    ];
    git-root = [
      pkgs.git
    ];
    screenshot-each-monitor = [
      pkgs.maim
      pkgs.jc
      pkgs.jq
      pkgs.xorg.xrandr
      pkgs.coreutils
    ];
    screenshot-each-monitor-wayland = [
      pkgs.grim
      pkgs.jq
      pkgs.wlr-randr
      pkgs.coreutils
    ];
    open-match = [
      pkgs.jq
      pkgs.coreutils
    ];
    ghq-gc = [
      pkgs.ghq
      pkgs.git
      pkgs.coreutils
    ];
    ghq-nvim-nix = [
      pkgs.fzf
      pkgs.gawk
      pkgs.moreutils
      pkgs.findutils
      pkgs.coreutils
      pkgs.gnused
      pkgs.git
      pkgs.nix
      pkgs.ghq
    ];
    ghq-nix-flake-update = [
      pkgs.jq
      pkgs.gh
      pkgs.ghq
      pkgs.coreutils
      pkgs.nix
      pkgs.git
      pkgs.gawk
    ];
    dua-nix = [ pkgs.dua ];
    npm-publish = [
      pkgs.nodejs
      pkgs.coreutils
    ];
    run-gh-workflow = [
      pkgs.findutils
      pkgs.yq
      pkgs.fzf
      pkgs.git
      pkgs.coreutils
    ];
    hyprctl-cycle-mfact = [
      pkgs.jq
      pkgs.hyprland
    ];
    chrome-by-email = [
      pkgs.jq
      pkgs.google-chrome
    ];
  };
in
pkgs.lib.mapAttrs' (name: runtimeInputs: {
  name = name;
  value = pkgs.writeShellApplication {
    name = name;
    runtimeInputs = runtimeInputs;
    inheritPath = false;
    text = builtins.readFile "${./scripts}/${name}.sh";
  };
}) scripts
