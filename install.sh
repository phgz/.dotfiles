#!/usr/bin/env bash

platform=$(uname -s)
arch=$(uname -m)

mkdir -p $HOME/.local/bin

#------------------------------------------------------------------------------#
#                                    MacOSX                                    #
#------------------------------------------------------------------------------#
if [ "$platform" == "Darwin" ]; then
    intel=/usr/local
    arm=/opt/homebrew

    if [ $arch == "x86_64" ]; then
        brew="$intel/bin/brew"

    else
        brew="$arm/bin/brew"
    fi

    #------------------------------------------------------------------------------#
    #                                   Homebrew                                   #
    #------------------------------------------------------------------------------#
    if [ ! -f $brew ]; then
        #export CI=1
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    #------------------------------------------------------------------------------#
    #                              kitty fish neovim                               #
    #------------------------------------------------------------------------------#
    $brew install kitty fish neovim tmux


#------------------------------------------------------------------------------#
#                                    Linux                                     #
#------------------------------------------------------------------------------#
elif [ "$platform" == "Linux" ]; then
    #------------------------------------------------------------------------------#
    #                              kitty fish neovim                               #
    #------------------------------------------------------------------------------#
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    ln -fs $HOME/.local/kitty.app/bin/kitty $HOME/.local/bin/

    #sudo apt-add-repository ppa:fish-shell/release-3
    #sudo apt update
    #sudo apt install fish

    curl -LJO https://github.com/neovim/neovim/releases/download/v0.6.1/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage $HOME/.local/bin/nvim
fi


#------------------------------------------------------------------------------#
#                                .config files                                 #
#------------------------------------------------------------------------------#
if [ ! -d $HOME/.config ]; then
    mkdir -p $HOME/.config
fi

for folder in $HOME/.dotfiles/*/
do
    ln -fs $folder $HOME/.config/
done

#------------------------------------------------------------------------------#
#                                     SSH                                      #
#------------------------------------------------------------------------------#
if [ ! -d $HOME/.ssh ]; then
    mkdir -p $HOME/.ssh
fi

cp $HOME/.dotfiles/ssh/* $HOME/.ssh
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/*

#------------------------------------------------------------------------------#
#                                  Cargo/Rust                                  #
#------------------------------------------------------------------------------#
if [ ! -d $HOME/.cargo ]; then
    mkdir -p $HOME/.cargo

    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
    cargo=$HOME/.cargo/bin/cargo
    $cargo install exa ripgrep bat fd-find du-dust
    $cargo install deno --locked
fi

#------------------------------------------------------------------------------#
#                                  Miniconda                                   #
#------------------------------------------------------------------------------#
if [ ! -d $HOME/.miniconda3 ]; then
    if [ $platform == "Darwin" ]; then
        platform_name=MacOSX
    elif [ $platform == "Linux" ]; then
        platform_name=Linux
    fi

    url_prefix=https://repo.anaconda.com/miniconda
    curl -L $url_prefix/Miniconda3-latest-$platform_name-$arch.sh -o miniconda.sh
    bash miniconda.sh -b -p $HOME/.miniconda3
    rm miniconda.sh
    $HOME/.miniconda3/bin/conda create --yes --name neovim python=3.9
    $HOME/.miniconda3/envs/neovim/bin/pip install toml gitpython pynvim autoflake black isort pyright
fi

#------------------------------------------------------------------------------#
#                                    Poetry                                    #
#------------------------------------------------------------------------------#
if [ ! -f $HOME/.local/bin/poetry ]; then
    curl -sSL https://install.python-poetry.org | python3 - --yes
fi

#------------------------------------------------------------------------------#
#                                   Starship                                   #
#------------------------------------------------------------------------------#
if [ ! -f $HOME/.local/bin/starship ]; then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir $HOME/.local/bin --yes
fi

#------------------------------------------------------------------------------#
#                         FantasqueSansMono Nerd Font                          #
#------------------------------------------------------------------------------#
curl -JLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FantasqueSansMono.zip
unzip FantasqueSansMono.zip -d FantasqueSansMono

if [ $platform == "Darwin" ]; then
    mkdir -p $HOME/Library/Fonts
    font_dest=$HOME/Library/Fonts

elif [ $platform == "Linux" ]; then
    mkdir -p $HOME/.local/share/fonts
    font_dest=$HOME/.local/share/fonts
fi

cp FantasqueSansMono/Fantasque\ Sans\ Mono\ *\ Font\ Complete.ttf $font_dest
fc-cache -f -v
rm FantasqueSansMono.zip && rm -rf FantasqueSansMono

#------------------------------------------------------------------------------#
#                                   Git hooks                                  #
#------------------------------------------------------------------------------#
#for folder in $HOME/*/
#do
#    ln -sf $HOME/.dotfiles/pre-commit $folder/.git/hooks/
#done
