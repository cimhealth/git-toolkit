#!/bin/bash
#初始化变量
function init() {
    COMMAND="command"
    CONFIG="config"
    HOOKS="hooks"

    SCRIPT_FILES="git-ci"
    TEMPLATE_FILES="git-message-template"

    USER_HOME="$(env|grep ^HOME=|cut -c 6-)"

    if [[ -z "$REPO_NAME" ]]; then
        REPO_NAME="git-toolkit"
    fi

    if [[ -z "$REPO_HOME" ]]; then
        REPO_HOME="https://github.com/cimhealth/git-toolkit.git"
    fi

    COMAND_PATHS=("/usr/local/bin" "$USER_HOME/bin")
    INSTALL_PATHS=("/usr/local/$REPO_NAME" "$USER_HOME/.$REPO_NAME")
    PATH_NUM=0
    uname -a|egrep -i linux && { echo $PATH|egrep /usr/local/sbin || PATH=$PATH:/usr/local/sbin ; }
    for p in "${COMAND_PATHS[@]}" ; do
        if [[ "$(echo $PATH | grep "${p}")" ]]; then
            touch "$p/git-toolkit-temp" > /dev/null 2>&1
            if [[ $? == 0 ]]; then
                COMMAND_PATH_PREFIX="$p"
                rm "$p/git-toolkit-temp" > /dev/null 2>&1
                break;
            fi
        fi
        PATH_NUM=$(($PATH_NUM+1))
    done
    if [[ $PATH_NUM =~ ^[0-$(expr ${#COMAND_PATHS[@]} - 1)] ]]; then
        INSTALL_PATH=${INSTALL_PATHS[PATH_NUM]}
    fi

    if [[ -z "$COMMAND_PATH_PREFIX" || -z "$INSTALL_PATH" ]]; then
        echo "$REPO_NAME Environment init failt!"
        exit 1;
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
        git clone "$REPO_HOME" "$INSTALL_PATH" || exit 1
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

uname -a|egrep -i linux &&  { [ `id -u` -eq 0 ] && init || { echo "Please  sudo  bash installer.sh " && exit 0 ; } ; } || init
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
