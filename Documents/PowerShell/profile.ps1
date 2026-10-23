# PowerShell counterpart of ~/.config/fish/config.fish, loaded by every host
# (terminal, VS Code, Rider).

# Add a directory to the front of the path when it exists and isn't there yet
function Add-PathEntry([string]$dir) {
    if ((Test-Path $dir) -and ($env:Path -split ';' -notcontains $dir)) {
        $env:Path = "$dir;$env:Path"
    }
}

# Add Starship configuration path
if (Test-Path "$HOME\.config\starship") {
    $env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
}

# Add local binaries (Claude Code, uv) to the path
Add-PathEntry "$HOME\.local\bin"

# Add Go workspace and its binaries to the path
if (Test-Path "$HOME\go") {
    $env:GOPATH = "$HOME\go"
    Add-PathEntry "$env:GOPATH\bin"
}

# Add Rust binaries to the path
Add-PathEntry "$HOME\.cargo\bin"

# Set Neovim as default editor
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# Set vi keybinding mode (PSReadLine only loads in interactive sessions)
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor
}

# List and tree views with eza, as the fish functions. Arguments go first:
# --icons and --hyperlink take an optional value and would swallow them.
function la { eza @args -la --header --icons --git --hyperlink }
function tree { eza @args --tree --git --hyperlink --icons }
function lt { eza @args -la --sort=modified --header --icons --git --hyperlink }   # newest last
function ldir { eza @args -lD --header --icons --git --hyperlink }                 # folders only
function tree2 { eza @args --tree --level=2 --git-ignore --git --hyperlink --icons }

# Set zoxide smarter cd (z, zi)
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })

    # Jump with zoxide, then open Neovim there: ze novel
    function ze { z @args; if ($?) { nvim . } }
}

# Set Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
