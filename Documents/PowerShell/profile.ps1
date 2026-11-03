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

# Render Markdown files as pages in the browser, offline (Pandoc): mdv README.md
function mdv {
    foreach ($path in $args) {
        $src = (Resolve-Path -LiteralPath $path -ErrorAction Stop).Path
        $out = Join-Path ([IO.Path]::GetTempPath()) "mdv\$([IO.Path]::GetFileNameWithoutExtension($src)).html"
        New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
        $common = @("--to=html5", "--standalone", "--embed-resources",
            "--css=$HOME/.config/pandoc/mdv.css", "--lua-filter=$HOME/.config/pandoc/mdv.lua",
            "--resource-path=$(Split-Path $src)", "--output=$out", $src)
        # Front matter that isn't valid YAML fails the first run; render it as text instead
        pandoc --from=gfm+yaml_metadata_block @common 2>$null
        if ($LASTEXITCODE -ne 0) { pandoc --from=gfm-yaml_metadata_block @common }
        if ($LASTEXITCODE -eq 0) { Invoke-Item $out }
    }
}

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
