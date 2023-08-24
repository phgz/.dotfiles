#!/usr/bin/env bash

platform=$(uname -s)
arch=$(uname -m)

# Linux sudo requirements: libevent-dev libncurses5-dev build-essential bison pkg-config cmake

FISH_SHELL_VERSION=3.6.1
TMUX_VERSION=3.3a
NODE_VERSION=20.5.1
POETRY_VERSION=1.6.1
PYTHON_VERSION=3.11

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

    $brew install fish node fontconfig wget python@"$PYTHON_VERSION" wezterm helix brave-browser dbeaver-community discord firefox opera postman rectangle slack subler transmission vlc zoom
    $brew install --HEAD neovim
    $brew tap finestructure/Hummingbird
    $brew install finestructure/hummingbird/hummingbird

    # Add Terminfo for wezterm:
    tempfile=$(mktemp) &&
        curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo &&
        /usr/bin/tic -x -o ~/.terminfo $tempfile &&
        rm $tempfile


#------------------------------------------------------------------------------#
#                                    Linux                                     #
#------------------------------------------------------------------------------#
elif [ "$platform" == "Linux" ]; then

    #------------------------------------------------------------------------------#
    #                                     Fish                                     #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/fish-shell/fish-shell/releases/download/"$FISH_SHELL_VERSION"/fish-"$FISH_SHELL_VERSION".tar.xz
    tar -xf fish-"$FISH_SHELL_VERSION".tar.xz && rm fish-"$FISH_SHELL_VERSION".tar.xz
    pushd fish-"$FISH_SHELL_VERSION" || exit
    mkdir build
    pushd build || exit
    cmake -DCMAKE_INSTALL_PREFIX="$HOME"/.local ..
    make && make install && popd || exit
    popd || exit

    rm -rf fish-"$FISH_SHELL_VERSION"

    #------------------------------------------------------------------------------#
    #                                     TMUX                                     #
    #------------------------------------------------------------------------------#
    curl -LJO https://github.com/tmux/tmux/releases/download/"$TMUX_VERSION"/tmux-"$TMUX_VERSION".tar.gz
    tar -xf tmux-*.tar.gz && rm tmux-"$TMUX_VERSION".tar.gz
    pushd tmux-*/ || exit
    pkg-config ./configure --prefix="$HOME"/.local --enable-static
    make && make install && popd || exit

    rm -rf tmux-*/

    # Add Terminfo for tmux:
    curl https://gist.githubusercontent.com/nicm/ea9cf3c93f22e0246ec858122d9abea1/raw/37ae29fc86e88b48dbc8a674478ad3e7a009f357/tmux-256color | /usr/bin/tic -x -

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
fi

#------------------------------------------------------------------------------#
#                                .config files                                 #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.config ]; then
    mkdir -p "$HOME"/.config
fi

for folder in "$HOME"/.dotfiles/*/; do
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
#                                  Cargo/Rust                                  #
#------------------------------------------------------------------------------#
if [ ! -d "$HOME"/.cargo ]; then
    mkdir -p "$HOME"/.cargo

    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
    cargo=$HOME/.cargo/bin/cargo
    PATH=/opt/homebrew/bin:$PATH $cargo install --locked exa ripgrep sd bat fd-find du-dust nu starship || exit

    git clone https://github.com/crescentrose/sunshine
    pushd sunshine || exit
    $cargo install --path .
    success=$?
    popd && rm -rf sunshine
    test $success -ne 0 && exit
fi

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
    curl -L $url_prefix/Miniconda3-latest-"$platform_name"-"$arch".sh -o miniconda.sh
    bash miniconda.sh -b -p "$HOME"/.miniconda3
    rm miniconda.sh
    "$HOME"/.miniconda3/bin/conda install --yes python="$PYTHON_VERSION" --channel conda-forge
    "$HOME"/.miniconda3/bin/conda create --yes --name neovim python="$PYTHON_VERSION" --channel conda-forge
    "$HOME"/.miniconda3/envs/neovim/bin/pip install pynvim
fi

#------------------------------------------------------------------------------#
#                                    Poetry                                    #
#------------------------------------------------------------------------------#
if [ ! -f "$HOME"/.local/bin/poetry ]; then
    curl -sSL https://install.python-poetry.org | POETRY_VERSION="$POETRY_VERSION" "$HOME"/.miniconda3/bin/python3 - --yes
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
mkdir FantasqueSansMono
curl -JLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FantasqueSansMono.tar.xz
tar --directory FantasqueSansMono -xf FantasqueSansMono.tar.xz && rm -rf FantasqueSansMono.tar.xz

if [ "$platform" == "Darwin" ]; then
    mkdir -p "$HOME"/Library/Fonts
    font_dest=$HOME/Library/Fonts

elif [ "$platform" == "Linux" ]; then
    mkdir -p "$HOME"/.local/share/fonts
    font_dest=$HOME/.local/share/fonts
fi

cp FantasqueSansMono/FantasqueSansMNerdFont-*.ttf "$font_dest"
fc-cache -f -v
rm -rf FantasqueSansMono
#------------------------------------------------------------------------------#
#                                   Git stuff                                  #
#------------------------------------------------------------------------------#
for folder in "$HOME"/*/; do
    ln -sf "$HOME"/.dotfiles/git/pre-commit "${folder%/*}"/.git/hooks/
done

sed "s/<<EMAIL>>/$(git log | head -2 | rg Author | sed -r 's/.*<(.*)>.*/\1/')/" "$HOME"/.dotfiles/git/gitconfig >"$HOME"/.gitconfig

#------------------------------------------------------------------------------#
#                                    Theme                                     #
#------------------------------------------------------------------------------#
if [ "$platform" == "Darwin" ]; then
    echo "Run the following command to enable theme daemons"
    echo "sudo cp $HOME/.dotfiles/theme/dotfiles.theme.plist /Library/LaunchDaemons/"
    echo "sudo launchctl load /Library/LaunchDaemons/dotfiles.theme.plist"
    # To test: sudo launchctl unload /Library/LaunchDaemons/dotfiles.theme.plist && sudo launchctl load /Library/LaunchDaemons/dotfiles.theme.plist && sudo launchctl list | rg dotfiles

elif [ "$platform" == "Linux" ]; then
    crontab -l | cat - "$HOME"/.dotfiles/theme/crontab | crontab -

    # Do not display login message
    touch "$HOME"/.hushlogin
fi
