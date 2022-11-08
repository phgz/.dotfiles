#!/usr/bin/env bash

platform=$(uname -s)
arch=$(uname -m)

BISON_VERSION=3.8.2
PKG_CONFIG_VERSION=0.29.2
LIBEVENT_VERSION=2.1.12
NCURSES_VERSION=6.3
CMAKE_VERSION=3.23.2
FISH_SHELL_VERSION=3.5.0
TMUX_VERSION=3.3a
NODE_VERSION=18.4.0
POETRY_VERSION=1.2.0b1
PYTHON_VERSION=3.10

mkdir -p "$HOME"/.local/bin

#------------------------------------------------------------------------------#
#                                    MacOSX                                    #
#------------------------------------------------------------------------------#
if [ "$platform" == "Darwin" ]; then
    intel=/usr/local
    arm=/opt/homebrew

    if [ "$arch" == "x86_64" ]; then
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
    $brew install kitty fish node yarn shellcheck neovim tmux fontconfig


#------------------------------------------------------------------------------#
#                               Linux (no root)                                #
#------------------------------------------------------------------------------#
elif [ "$platform" == "Linux" ]; then

    #------------------------------------------------------------------------------#
    #                                 Dependencies                                 #
    #------------------------------------------------------------------------------#
    curl -JLO http://ftp.gnu.org/gnu/bison/bison-"$BISON_VERSION".tar.gz
    tar xfz bison-"$BISON_VERSION".tar.gz && rm -rf bison-"$BISON_VERSION".tar.gz
    pushd bison-"$BISON_VERSION"/ || exit
    ./configure --prefix="$HOME"/.local
    make && make install && popd || exit

    curl -JLO https://pkg-config.freedesktop.org/releases/pkg-config-"$PKG_CONFIG_VERSION".tar.gz
    tar xfz pkg-config-"$PKG_CONFIG_VERSION".tar.gz && rm -rf pkg-config-"$PKG_CONFIG_VERSION".tar.gz
    pushd pkg-config-"$PKG_CONFIG_VERSION"/ || exit
    ./configure --prefix="$HOME"/.local --with-internal-glib
    make && make install && popd || exit

    curl -LJO https://github.com/libevent/libevent/releases/download/release-"$LIBEVENT_VERSION"-stable/libevent-"$LIBEVENT_VERSION"-stable.tar.gz
    tar -zxf libevent-*.tar.gz && rm libevent-"$LIBEVENT_VERSION"-stable.tar.gz
    pushd libevent-*/ || exit
    ./configure --prefix="$HOME"/.local --enable-shared --disable-openssl
    make && make install && popd || exit

    curl -LJO https://invisible-mirror.net/archives/ncurses/ncurses-"$NCURSES_VERSION".tar.gz
    tar -zxf ncurses-"$NCURSES_VERSION".tar.gz && rm ncurses-"$NCURSES_VERSION".tar.gz
    pushd ncurses-*/ || exit
    ./configure --prefix="$HOME"/.local --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir="$HOME"/.local/lib/pkgconfig
    make && make install && popd || exit

    curl -LJO https://github.com/Kitware/CMake/releases/download/v"$CMAKE_VERSION"/cmake-"$CMAKE_VERSION"-linux-"$arch".tar.gz
    tar xvzf cmake-"$CMAKE_VERSION"-linux-"$arch".tar.gz && rm cmake-"$CMAKE_VERSION"-linux-x86_64.tar.gz || exit

    #------------------------------------------------------------------------------#
    #                                    Kitty                                     #
    #------------------------------------------------------------------------------#
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    ln -fs "$HOME"/.local/kitty.app/bin/kitty "$HOME"/.local/bin/

    #------------------------------------------------------------------------------#
    #                                     Fish                                     #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/fish-shell/fish-shell/releases/download/"$FISH_SHELL_VERSION"/fish-"$FISH_SHELL_VERSION".tar.xz
    tar xf fish-"$FISH_SHELL_VERSION".tar.xz && rm fish-"$FISH_SHELL_VERSION".tar.xz
    pushd fish-"$FISH_SHELL_VERSION" || exit
    mkdir build
    pushd build || exit
    ../../cmake-"$CMAKE_VERSION"-linux-"$arch"/bin/cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local ..
    # Try this instead if previous line fails:
    # ../../cmake-"$CMAKE_VERSION"-linux-"$arch"/bin/cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local -DCMAKE_CXX_FLAGS=-I\ "$HOME"/.local/include/ncurses ..
    make && make install && popd || exit
    popd || exit

    rm -rf fish-"$FISH_SHELL_VERSION"

    #------------------------------------------------------------------------------#
    #                                     TMUX                                     #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/tmux/tmux/releases/download/"$TMUX_VERSION"/tmux-"$TMUX_VERSION".tar.gz
    tar -zxf tmux-*.tar.gz && rm tmux-"$TMUX_VERSION".tar.gz
    pushd tmux-*/ || exit
    PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix="$HOME"/.local --enable-static
    make && make install && popd || exit

    rm -rf tmux-*/

    # Add Terminfo for tmux:
    # curl https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color | tic -x -

    #------------------------------------------------------------------------------#
    #                                    Neovim                                    #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage "$HOME"/.local/bin/nvim

    #------------------------------------------------------------------------------#
    #                                    Nodejs                                    #
    #------------------------------------------------------------------------------#
    curl -LJO https://nodejs.org/dist/v"$NODE_VERSION"/node-v"$NODE_VERSION"-linux-x64.tar.xz
    tar -xf node-v"$NODE_VERSION"-linux-x64.tar.xz && rm node-v"$NODE_VERSION"-linux-x64.tar.xz
    mv node-v"$NODE_VERSION"-linux-x64 "$HOME"/.local/node

    PATH=$HOME/.local/node/bin:$PATH "$HOME"/.local/node/bin/corepack enable
    PATH=$HOME/.local/node/bin:$PATH "$HOME"/.local/node/bin/npm install -g neovim
    PATH=$HOME/.local/node/bin:$PATH "$HOME"/.local/node/bin/npm install -g bash-language-server

    #------------------------------------------------------------------------------#
    #                       Remove dependencies src folders                        #
    #------------------------------------------------------------------------------#
    rm -rf ncurses-*/ libevent-*/ cmake-*/ pkg-config-*/ bison-*/
fi

#------------------------------------------------------------------------------#
#                                .config files                                 #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.config ]; then
    mkdir -p "$HOME"/.config
fi

for folder in "$HOME"/.dotfiles/*/
do
    ln -fs "$folder" "$HOME"/.config/ || (rm -rf "$HOME"/.config/"$(basename "$folder")" && ln -fs "$folder" "$HOME"/.config/)
done

#------------------------------------------------------------------------------#
#                                     SSH                                      #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.ssh ]; then
    mkdir -p "$HOME"/.ssh
fi

cp "$HOME"/.dotfiles/ssh/* "$HOME"/.ssh
chmod 700 "$HOME"/.ssh
chmod 600 "$HOME"/.ssh/*

#------------------------------------------------------------------------------#
#                                  Miniconda                                   #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.miniconda3 ]; then
    if [ "$platform" == "Darwin" ]; then
        platform_name=MacOSX
    elif [ "$platform" == "Linux" ]; then
        platform_name=Linux
    fi

    url_prefix=https://repo.anaconda.com/miniconda
    curl -L $url_prefix/Miniconda3-latest-$platform_name-"$arch".sh -o miniconda.sh
    bash miniconda.sh -b -p "$HOME"/.miniconda3
    rm miniconda.sh
    "$HOME"/.miniconda3/bin/conda install --yes python="$PYTHON_VERSION"
    "$HOME"/.miniconda3/bin/conda create --yes --name neovim python="$PYTHON_VERSION"
    "$HOME"/.miniconda3/envs/neovim/bin/pip install toml gitpython pynvim autoflake black isort pyright
    "$HOME"/.miniconda3/bin/conda install --yes -c conda-forge shellcheck
fi

#------------------------------------------------------------------------------#
#                                  Cargo/Rust                                  #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.cargo ]; then
    mkdir -p "$HOME"/.cargo

    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
    cargo=$HOME/.cargo/bin/cargo
    $cargo install exa ripgrep bat fd-find du-dust || exit
    $cargo install deno --locked || exit
fi

#------------------------------------------------------------------------------#
#                                    Poetry                                    #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/poetry ]; then
    curl -sSL https://install.python-poetry.org | POETRY_VERSION="$POETRY_VERSION" "$HOME"/.miniconda3/bin/python3 - --yes
fi

#------------------------------------------------------------------------------#
#                                   Starship                                   #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/starship ]; then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir "$HOME"/.local/bin --yes
fi

#------------------------------------------------------------------------------#
#                                    Direnv                                    #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/direnv ]; then
curl -sfL https://direnv.net/install.sh | bin_path=~/.local/bin bash
fi

#------------------------------------------------------------------------------#
#                         FantasqueSansMono Nerd Font                          #
#------------------------------------------------------------------------------#

# https://github.com/be5invis/Iosevka # To try
curl -JLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FantasqueSansMono.zip
unzip FantasqueSansMono.zip -d FantasqueSansMono

if [ "$platform" == "Darwin" ]; then
    mkdir -p "$HOME"/Library/Fonts
    font_dest=$HOME/Library/Fonts

elif [ "$platform" == "Linux" ]; then
    mkdir -p "$HOME"/.local/share/fonts
    font_dest=$HOME/.local/share/fonts
fi

cp FantasqueSansMono/Fantasque\ Sans\ Mono\ *\ Font\ Complete.ttf "$font_dest"
fc-cache -f -v
rm FantasqueSansMono.zip && rm -rf FantasqueSansMono

#------------------------------------------------------------------------------#
#                                   Git hooks                                  #
#------------------------------------------------------------------------------#
for folder in "$HOME"/*/
do
   ln -sf "$HOME"/.dotfiles/git/pre-commit "${folder%/*}"/.git/hooks/
done

#------------------------------------------------------------------------------#
#                                    Theme                                     #
#------------------------------------------------------------------------------#
if [ "$platform" == "Darwin" ]; then
    echo "Run the following command to enable theme daemons"
    echo "sudo mv $HOME/.dotfiles/theme/dotfiles.theme.{light,dark}.plist /Library/LaunchDaemons/"
    echo "sudo launchctl load /Library/LaunchDaemons/dotfiles.theme.{light,dark}.plist"

elif [ "$platform" == "Linux" ]; then
    crontab -l | cat - "$HOME"/.dotfiles/theme/linux.txt | crontab -

    # Do not display login message
    touch "$HOME"/.hushlogin
fi
