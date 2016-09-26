#!/bin/sh
#初始化变量
function init() {
    COMMAND="command"
    CONFIG="config"
    HOOKS="hooks"

    SCRIPT_FILES="git-ci"
    TEMPLATE_FILES="git-message-template"
    HOOK_FILES="commit-msg"

    if [[ -z "$REPO_NAME" ]]; then
        REPO_NAME="git-toolkit"
    fi

    if [[ -z "$REPO_HOME" ]]; then
        REPO_HOME="git@github.com:tonydeng/git-toolkit.git"
    fi
    if [[ -z "$COMMAND_PATH_PREFIX" ]]; then
        COMMAND_PATH_PREFIX="/usr/local/bin"
    fi
    if [[ -z "$INSTALL_PATH" ]]; then
        INSTALL_PATH="~/.$REPO_NAME"
    fi
}
# 卸载
function uninstall() {
    if [[ -d "$INSTALL_PATH" && -d "$INSTALL_PATH/.git" ]]; then
        echo "Uninstalling git-toolkit."
        rm -rf "$INSTALL_PATH"
    fi

    if [ -d "$COMMAND_PATH_PREFIX" ] ; then
        echo "Uninstalling git-toolkit command from $COMMAND_PATH_PREFIX"
        for script_file in $SCRIPT_FILES ; do
            echo "rm -vf $COMMAND_PATH_PREFIX/$script_file"
            rm -vf "$COMMAND_PATH_PREFIX/$script_file"
        done
    else
        echo "The '$COMMAND_PATH_PREFIX' directory was not found."
        echo "Do you need to set COMMAND_PATH_PREFIX ?"
    fi

    git config --global --unset commit.template
    git config --global --unset core.hooksPath
}

function help() {
    echo "Usage: [environment] git-toolkit installer.sh [install|uninstall]"
    echo "Environment:"
    echo "   COMMAND_PATH_PREFIX=$COMMAND_PATH_PREFIX"
    echo "   INSTALL_PATH=$INSTALL_PATH"
}

function install() {
    echo "Installing git-toolkit to $COMMAND_PATH_PREFIX"
    clone
    install_cmd
    install_config
    install_hooks
}

function clone() {
    if [ -d "$INSTALL_PATH" -a -d "$INSTALL_PATH/.git" ] ; then
        echo "Using existing repo: $REPO_NAME"
        cd $INSTALL_PATH
        git pull
        cd -
    else
        echo "Cloning repo from GitHub to $INSTALL_PATH"
        git clone "$REPO_HOME" "$INSTALL_PATH"
        chmod -R 755 $INSTALL_PATH/$COMMAND
        chmod -R 755 $INSTALL_PATH/$HOOKS
    fi
}

function install_cmd() {
    echo "Install Git Command......"
    mkdir -p $COMMAND_PATH_PREFIX
    for script_file in $SCRIPT_FILES ; do
        ln -s "$INSTALL_PATH/$COMMAND/$script_file" "$COMMAND_PATH_PREFIX/$script_file"
    done
}

function install_config() {
    echo "Install Git Config......"
    ALIAS=`git config --list|grep 'alias.ci'`
    if [[ -n "$ALIAS" ]]; then
        git config --global --unset alias.ci
    fi
    git config --global commit.template "$INSTALL_PATH/$CONFIG/$TEMPLATE_FILES"
}

function install_hooks() {
    echo "Install Git Hooks......"
    git config core.hooksPath "$INSTALL_PATH/$HOOKS"
}

echo "### git-toolkit no-make installer ###"
init
case $1 in
    uninstall)
        uninstall
		exit
        ;;
    help)
        help
        exit
        ;;
    *)
		install
		exit
        ;;
esac
