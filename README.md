# Personal system configuration
This repository is released with the BSD3 license.

## Usage
This repository contains a set of configuration files for the shell and tools used for the normal usage workflow. The repository is meant to be cloned in the hard drive (personally I keep it in the $HOME directory of my user) where the exposed configuration files can be linked. To link the necessary files run from the repository directory.

    ln -s bashrc $HOME/.bashrc
    ln -s gitignore_global $HOME/.gitignore_global
    ln -s gvimrc $HOME/.gvimrc
    ln -s init.vim $XDG_CONFIG_HOME/nvim/init.vim
    ln -s tmux.conf $HOME/.tmux.conf
    ln -s vimrc $HOME/.vimrc
