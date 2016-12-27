# Git Toolkit


> 人类懒惰的本性和不满足的本性是驱使科技发展的源泉......

## 安装

**使用curl**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tonydeng/git-toolkit/master/installer.sh)"
```

**使用wget**

```bash
bash -c "$(wget https://raw.githubusercontent.com/tonydeng/git-toolkit/master/installer.sh -O -)"
```

## git toolkit介绍

本工具集包含几个部分，自定义命令，Hook脚本，以及配置模板

### 自定义命令

#### git toolkit

提供本工具集的管理命令。

**查看帮助**

```bash
git toolkit help
```

**卸载本工具集**

```bash
git toolkit uninstall
```

**更新本工具集**

```bash
git toolkit update
```

#### git ci

提供交互式`git commit`的命令，用于定制统一`commit message`。

> 用于替换[Commitizen](https://github.com/commitizen/cz-cli)

```bash
git ci
选择您正在提交的类型:
        1. backlog: 开始一个新的backlog
        2. feat: 新功能（feature）
        3. fix: 修补bug
        4. docs: 文档（documentation）
        5. style: 格式（不影响代码运行的变动）
        6. refactor: 重构（即不是新增功能，也不是修改bug的代码变动）
        7. test: 增加测试
        8. chore: 构建过程或辅助工具的变动
        0. quit: 退出
```    

### Hook脚本

#### commit-msg

用于验证每次提交的`commit message`是否符合规范，如果不符合规范，则提交不成功

### 配置

#### git config --global commit.template

配置统一的`commit message`模板

#### git config --global core.hooksPath

配置制定的Hook脚本的目录，使用本项目的git hook脚本
