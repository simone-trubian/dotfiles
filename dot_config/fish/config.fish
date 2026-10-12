#  
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# Add Starship configuration path
if test -d $HOME/.config/starship
    set -x STARSHIP_CONFIG $HOME/.config/starship/starship.toml
end

# Put Homebrew ahead of the macOS system binaries
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

# Add local binaries (Antigravity, Claude Code) to the path
fish_add_path --global --path $HOME/.local/bin

# Add Go workspace and its binaries to the path
if test -d $HOME/go
    set -gx GOPATH $HOME/go
    fish_add_path --global --path $GOPATH/bin
end

# Add Rust binaries to the path
fish_add_path --global --path $HOME/.cargo/bin

# Add Opam configuration
if test -f $HOME/.opam/opam-init/init.fish
    source $HOME/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true
end

# Set Neovim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Set vi keybding mode
set -g fish_key_bindings fish_vi_key_bindings

mise activate fish | source

# Set Starship prompt
starship init fish | source
