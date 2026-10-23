# Arguments go first: --icons and --hyperlink take an optional value and
# would swallow a directory placed after them.
function la
    eza $argv -la --header --icons --git --hyperlink
end
