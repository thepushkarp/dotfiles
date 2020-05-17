#!/usr/bin/bash

cd "$(dirname "${BASH_SOURCE}")";

echo "Fetching most recent version..."
git pull origin master;

function doIt() {
    declare -a FILES
    declare -a NVIMFILES

    FILES=(
        editorconfig
        gitconfig
        gitignore_global
        gitmessage
        tmux.conf
        zshrc
        p10k.zsh
        rvmrc
    )

    NVIMFILES=(
        init.vim
        plugins.vim
    )

    for FILE in ${FILES[@]}; do

        CURR_FILE=./$FILE
        DEST_FILE=$HOME/.$FILE

        if [ -f "$DEST_FILE" ]; then
            BCK_FILE=$DEST_FILE.bak
            echo "Backing up existing $DEST_FILE to $BCK_FILE"
            cp -L $DEST_FILE $BCK_FILE
            rm $DEST_FILE
            ln $CURR_FILE $DEST_FILE
        else
            ln $CURR_FILE $DEST_FILE
        fi

    done

for FILE in ${NVIMFILES[@]}; do

        CURR_FILE=./$FILE
        DEST_FILE=$HOME/.config/nvim/$FILE

        if [ -f "$DEST_FILE" ]; then
            BCK_FILE=$DEST_FILE.bak
            echo "Backing up existing $DEST_FILE to $BCK_FILE"
            cp -L $DEST_FILE $BCK_FILE
            rm $DEST_FILE
            ln $CURR_FILE $DEST_FILE
        else
            ln $CURR_FILE $DEST_FILE
        fi

    done

    echo "Done!"
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;

unset doIt;
