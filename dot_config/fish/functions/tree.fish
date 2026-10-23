# Arguments go first: --icons and --hyperlink take an optional value and
# would swallow a directory placed after them.
function tree
    eza $argv --tree --git --hyperlink --icons
end
