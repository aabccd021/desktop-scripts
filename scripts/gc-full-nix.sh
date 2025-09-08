doas echo starting garbage collection

nix-env -u --always
nix-collect-garbage -d

doas nix-channel --update
doas nix-env -u --always

# https://nixos.org/guides/nix-pills/11-garbage-collector#indirect-roots
# removes all build result from `nix build` command
doas rm /nix/var/nix/gcroots/auto/*

doas nix-collect-garbage -d
doas nix-store --optimise
