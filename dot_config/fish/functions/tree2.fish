# Two levels deep, skipping what git ignores (build/, node_modules ...)
function tree2
    eza $argv --tree --level=2 --git-ignore --git --hyperlink --icons
end
