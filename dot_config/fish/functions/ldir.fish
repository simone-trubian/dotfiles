# Folders only. Not "ld", which would hide the system linker.
function ldir
    eza $argv -lD --header --icons --git --hyperlink
end
