#!/usr/bin/env bash

platform=$(uname -s)
arch=$(uname -m)

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
    curl -JLO http://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.gz
    tar xfz bison-3.8.2.tar.gz && rm -rf bison-3.8.2.tar.gz
    pushd bison-3.8.2/ || exit
    ./configure --prefix="$HOME"/.local
    make && make install
    popd

    curl -JLO https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
    tar xfz pkg-config-0.29.2.tar.gz && rm -rf pkg-config-0.29.2.tar.gz
    pushd pkg-config-0.29.2/ || exit
    ./configure --prefix="$HOME"/.local --with-internal-glib
    make && make install
    popd

    curl -LJO https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
    tar -zxf libevent-*.tar.gz && rm libevent-2.1.12-stable.tar.gz
    pushd libevent-*/ || exit
    ./configure --prefix="$HOME"/.local --enable-shared --disable-openssl
    make && make install
    popd

    curl -LJO https://invisible-island.net/datafiles/release/ncurses.tar.gz
    tar -zxf ncurses.tar.gz && rm ncurses.tar.gz
    pushd ncurses-*/ || exit
    ./configure --prefix="$HOME"/.local --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir="$HOME"/.local/lib/pkgconfig
    make && make install
    popd

    curl -LJO https://github.com/Kitware/CMake/releases/download/v3.22.3/cmake-3.22.3-linux-x86_64.tar.gz
    tar xvzf cmake-3.22.3-linux-x86_64.tar.gz && rm cmake-3.22.3-linux-x86_64.tar.gz

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
    ../../cmake-3.22.3-linux-x86_64/bin/cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local ..
    make && make install
    popd
    popd

    rm -rf fish-"$FISH_SHELL_VERSION"

    #------------------------------------------------------------------------------#
    #                                     TMUX                                     #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz
    tar -zxf tmux-*.tar.gz && rm tmux-3.3a.tar.gz
    pushd tmux-*/ || exit
    PKG_CONFIG_PATH=$HOME/.local/lib/pkgconfig ./configure --prefix="$HOME"/.local
    make && make install
    popd

    rm -rf tmux-*/

    #------------------------------------------------------------------------------#
    #                                    Neovim                                    #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage "$HOME"/.local/bin/nvim

    #------------------------------------------------------------------------------#
    #                                    Nodejs                                    #
    #------------------------------------------------------------------------------#
    nodeV=18.0.0
    curl -LJO https://nodejs.org/dist/v$nodeV/node-v$nodeV-linux-x64.tar.xz
    tar -xf node-v$nodeV-linux-x64.tar.xz
    rm node-v$nodeV-linux-x64.tar.xz
    mv node-v$nodeV-linux-x64 "$HOME"/.local/node

    "$HOME"/.local/node/bin/corepack enable
    "$HOME"/.local/node/bin/npm install -g neovim

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
    ln -fs "$folder" "$HOME"/.config/
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
    "$HOME"/.miniconda3/bin/conda create --yes --name neovim python=3.9
    "$HOME"/.miniconda3/envs/neovim/bin/pip install toml gitpython pynvim autoflake black isort pyright
    "$HOME"/.miniconda3/bin/conda install -c conda-forge shellcheck
fi

#------------------------------------------------------------------------------#
#                             bash-language-server                             #
#------------------------------------------------------------------------------#
git clone https://github.com/shabbyrobe/bash-language-server
pushd bash-language-server || exit
git remote add upstream https://github.com/bash-lsp/bash-language-server
git fetch upstream
git merge upstream/master --no-edit
yarn install && yarn run compile && yarn run reinstall-server
popd

#------------------------------------------------------------------------------#
#                                  Cargo/Rust                                  #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.cargo ]; then
    mkdir -p "$HOME"/.cargo

    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
    cargo=$HOME/.cargo/bin/cargo
    $cargo install exa ripgrep bat fd-find du-dust
    $cargo install deno --locked
fi

#------------------------------------------------------------------------------#
#                                    Poetry                                    #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/poetry ]; then
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.2.0b1 "$HOME"/.miniconda3/bin/python3 - --yes
fi

#------------------------------------------------------------------------------#
#                                   Starship                                   #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/starship ]; then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir "$HOME"/.local/bin --yes
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
for folder in $HOME/*/
do
   ln -sf $HOME/.dotfiles/pre-commit $folder/.git/hooks/
done

#------------------------------------------------------------------------------#
#                                   Cronjobs                                   #
#------------------------------------------------------------------------------#
crontab -l | cat - "$HOME"/.dotfiles/cronjobs.txt | crontab -
