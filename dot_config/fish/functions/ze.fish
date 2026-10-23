# Jump with zoxide, then open Neovim there: ze novel
function ze
    z $argv; and nvim .
end
