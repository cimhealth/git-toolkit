#!/bin/bash
#初始化变量
function init() {
    COMMAND="command"
    CONFIG="config"
    HOOKS="hooks"

    SCRIPT_FILES="git-ci"
    TEMPLATE_FILES="git-message-template"

    if [[ -z "$REPO_NAME" ]]; then
        REPO_NAME="git-toolkit"
    fi

    if [[ -z "$REPO_HOME" ]]; then
        REPO_HOME="https://github.com/tonydeng/git-toolkit.git"
    fi
    if [[ -z "$COMMAND_PATH_PREFIX" ]]; then
        COMMAND_PATH_PREFIX="/usr/local/bin"
    fi
    if [[ -z "$INSTALL_PATH" ]]; then
        INSTALL_PATH="/usr/local/$REPO_NAME"
    fi
}
# 卸载
function uninstall() {
    if [[  -d "$INSTALL_PATH" ]]; then
        echo "Uninstalling $REPO_NAME"
        rm -rf "$INSTALL_PATH"
    else
        echo "$INSTALL_PATH is no existing."
    fi

    if [ -d "$COMMAND_PATH_PREFIX" ] ; then
        echo "Uninstalling $REPO_NAME command from $COMMAND_PATH_PREFIX"
        for script_file in $SCRIPT_FILES ; do
            echo "rm -vf $COMMAND_PATH_PREFIX/$script_file"
            rm -vf "$COMMAND_PATH_PREFIX/$script_file"
        done

        rm -vf "$COMMAND_PATH_PREFIX/$REPO_NAME"
    else
        echo "The '$COMMAND_PATH_PREFIX' directory was not found."
        echo "Do you need to set COMMAND_PATH_PREFIX ?"
    fi

    git config --global --unset commit.template
    git config --global --unset core.hooksPath
}

# 使用帮助
function help() {
    echo "Usage: [environment] $REPO_NAME installer.sh [install|uninstall|update]"
    echo "Environment:"
    echo "   COMMAND_PATH_PREFIX=$COMMAND_PATH_PREFIX"
    echo "   INSTALL_PATH=$INSTALL_PATH"
}

# 安装 git-toolkit
function install() {
    echo "Installing $REPO_NAME to $COMMAND_PATH_PREFIX"
    clone
    install_cmd
    install_config
    install_hooks
}

function update() {
    echo "Update $REPO_NAME"
    install
}

# clone项目
function clone() {
    if [ -d "$INSTALL_PATH" ] && [ -d "$INSTALL_PATH/.git" ] ; then
        echo "Using existing repo: $REPO_NAME"
        cd $INSTALL_PATH || exit 1
        git pull
        cd -  ||  exit 1
    else
        echo "Cloning repo from GitHub to $INSTALL_PATH"
        git clone "$REPO_HOME" "$INSTALL_PATH"
        chmod -R 755 "$INSTALL_PATH/$COMMAND"
        chmod -R 755 "$INSTALL_PATH/$HOOKS"
    fi
}

# 安装命令
function install_cmd() {
    echo "Install Git Command......"
    mkdir -p $COMMAND_PATH_PREFIX
    for script_file in $SCRIPT_FILES ; do
        ln -s "$INSTALL_PATH/$COMMAND/$script_file" "$COMMAND_PATH_PREFIX/$script_file" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$script_file installed."
    done

    ln -s "$INSTALL_PATH/installer.sh" "$COMMAND_PATH_PREFIX/$REPO_NAME" > /dev/null 2>&1 || echo "$COMMAND_PATH_PREFIX/$REPO_NAME installed."
}
# 安装配置
function install_config() {
    echo "Install Git Config......"
    ALIAS=`git config --list|grep 'alias.ci'`
    if [[ -n "$ALIAS" ]]; then
        git config --global --unset alias.ci
    fi
    git config --global commit.template "$INSTALL_PATH/$CONFIG/$TEMPLATE_FILES"
}

# 安装hook脚本
function install_hooks() {
    echo "Install Git Hooks......"
    git config --global core.hooksPath "$INSTALL_PATH/$HOOKS"
}

init
echo "### $REPO_NAME no-make installer ###"
case $1 in
    uninstall)
        uninstall
		exit
        ;;
    update)
        update
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
