#!/bin/bash
SOURCE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function install() {
    local dst="$HOME/$2"
    local dst_name=$(basename "$dst")
    local dst_dir=$(dirname "$dst")
    local src="$SOURCE_DIR/$1"

    echo "Symlink '$src' -> '$dst'"
    pushd "$dst_dir" >/dev/null || exit 1
    ln -sfrn "$src" "$dst_name" || exit 1
    popd >/dev/null
}

function dot_file() {
    install "$1" ."$1"
}
dot_file gitconfig
dot_file tmux.conf
dot_file vimrc
dot_file zshrc
dot_file config/git
dot_file config/powerline
