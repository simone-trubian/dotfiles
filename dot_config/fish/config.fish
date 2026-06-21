#  
string match -q "$TERM_PROGRAM" vscode
and . (code --locate-shell-integration-path fish)

# Add Starship configuration path
if test -d $HOME/.config/starship
    set -x STARSHIP_CONFIG $HOME/.config/starship/starship.toml
end

# Add Antigravity binaries to the path
if test -d $HOME/.local/bin
    set -x PATH $HOME/.local/bin
end

# Add Go binaries to the path
if test -d /usr/local/go
    set -x PATH /usr/local/go/bin $PATH
end

# Add Go workspace binaries to the path
if test -d $HOME/go
    set -x PATH $HOME/go/bin $PATH
end

# Add Go workspace to the path
if test -d $HOME/go
    set -x GOPATH $HOME/go
end

# Add Java 8 binaries to the path
if test -d /usr/lib/jvm/java-8-oracle
    set -x JAVA_HOME /usr/lib/jvm/java-8-oracle
end

# Add Rust binaries to the path
if test -d $HOME/.cargo/bin/
    set -x PATH $HOME/.cargo/bin/ $PATH
end

# Add Rust toolchain sources
if test -d $HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/
    set -x RUST_SRC_PATH $HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/
end

# Add Protoc protobuf compiler
if test -d /usr/local/protoc
    set -x PATH /usr/local/protoc/bin $PATH
end

# Add Python Poetry to the path
if test -d $HOME/.poetry/bin/
    set -x PATH $HOME/.poetry/bin/ $PATH
end

# Add Opam configuration
if test -d $HOME/.opam/
    source /home/simone/.opam/opam-init/init.fish >/dev/null 2>/dev/null; or true
end

# Set Neovim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Set vi keybding mode
set -g fish_key_bindings fish_vi_key_bindings

mise activate fish | source

# Set Starship prompt
starship init fish | source
