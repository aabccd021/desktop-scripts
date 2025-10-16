input="$1"

mkdir --parents "$XDG_CACHE_HOME/nix-gcroots"
nix build "$input" --out-link "$XDG_CACHE_HOME/nix-gcroots/$input"
