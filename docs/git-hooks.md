# Git Hooks
Git Hooks是相对比较高级的使用技巧。

相应介绍可以查看Git官方的文档：[Git Hooks英文版](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks),[Git Hooks中文版](https://git-scm.com/book/zh/v2/%E8%87%AA%E5%AE%9A%E4%B9%89-Git-Git-%E9%92%A9%E5%AD%90)

## hook简单对比列表
|钩子名字 | 触发命令 | 参数 | 非0导致取消 | 备注 |
|--|--|--|--|--|
|applypatch-msg    |git am      |1   | Yes | -- |
|pre-applypatch    |git am      |0   | Yes | -- |
|post-applypatch   |git am      |0   | No | -- |
|pre-commit        |git commit  |0   | Yes| -- |
|prepare-commit-msg|git commit  |1~3 | Yes| -- |
|commit-msg        |git commit  |1   | Yes| -- |
|post-commit       |git commit  |0   | No | -- |
|pre-rebase        |git rebase  |2   | Yes| -- |
|post-checkout     |git checkout|3   | No | -- |
|post-merge        |git merge   |1   | No | -- |
|pre-receive       |git-receive-pack |0   | Yes|通过标准输入获取信息|
|update            |git-receive-pack |3   | Yes| -- |
|post-receive      |git-receive-pack |0   | No |通过标准输入获取信息|
|post-update |git-receive-pack |可变| No | --|

## hook详细介绍

### applypatch-msg

这个hook由`git am`脚本触发. 它将接受一个参数,即将提交的`commit msg`的临时文件路径.
如果这个`hook`以非0状态退出,那么`git am`将在`patch`(补丁)应用之前取消.

这个`hook`可以用于修改`message`(信息)文件, 用来匹配项目的规范格式(如果有的话).
也可以用于校验`commit msg`,并在必要时拒绝提交.

缺省的`applypatch-msg` `hook`, 当其启用时,将调用`commit-msg` `hook`.

### pre-applypatch

这个`hook`由`git am`脚本触发.  它并不接受参数, 当`patch`(补丁信息)已经应用,且`commit`尚未执行
之前被调用.

如果以非0状态退出, 那么`working tree`(工作树)将不会被提交,但`patch`已经被应用.

它可以用于检查当前的`working tree`(工作树),当其无法通过某个特定测试时,拒绝进行提交.

缺省的`pre-applypatch` `hook`, 当其启用时,将调用`pre-commit` `hook`.

### post-applypatch

这个`hook`由`git am`脚本触发.  它并不接受参数, 在`patch`已经应用且`commit`已经完成后执行.

这个`hook`主要用于通知, 而且对`git am`的输出无影响.

### pre-commit

这个`hook`由`git commit`触发, 且可以通过`--no-verify` 来略过.  它并不接受参数, 在`commit msg`被创建之前执行.  
如果以非0状态退出,将导致`git commit`被取消.

缺省的`pre-commit` `hook`, 当启用时, 将捕捉以空白字符结尾的行,如果找到这样的行,则取消提交.
(译者注: 事实上并非如此,而是查找非`ascii`文件名!!)

所有的`git commit` `hooks`在执行时,如果没有指定编辑器,那么都附带一个环境变量`GIT_EDITOR=:`

### prepare-commit-msg

这个`hook`由`git commit`,在准备好默认`log`信息后触发,但此时,编辑器尚未启动.

它可能接受1到3个参数.
第一个参数是包含`commit msg`的文件路径.
第二个参数是commit msg的来源, 可能的值有:
  `message` (当使用`-m` 或`-F` 选项);
  `template` (当使用`-t` 选项,或`commit.template`配置项已经被设置);
  `merge` (当commit是一个merge或者`.git/MERGE_MSG`存在);
  `squash`(当`.git/SQUASH_MSG`文件存在);
  `commit`, 且附带该`commit`的`SHA1` (当使用`-c`, `-C` 或 `--amend`).

如果以非0状态退出, `git commit` 将会被取消.

这个`hook`的目的是修改`message`文件,且不受`--no-verify`的影响.  
本`hook`以非0状态退出,则代表当前`hook`失败,并取消提交.它不应该取代`pre-commit` hook.

示例`prepare-commit-msg` `hook`是准备一个`merge`的冲突列表.

### commit-msg

这个`hook`由`git commit`触发, 且可以通过`--no-verify` 来略过.
它接受一个参数, 包含`commit msg`的文件的路径.

如果以非0状态退出, `git commit` 将会被取消.

这个`hook`可以用于修改`message`(信息)文件, 用来匹配项目的规范格式(如果有的话).
也可以用于校验`commit msg`,并在必要时拒绝提交.

缺省的`commit-msg` `hook`, 当启用时,将检查重复的`"Signed-off-by"`行, 如果找到,则取消`commit`.

### post-commit

这个`hook`由`git commit`触发.  它不接受参数, 当`commit`完成后执行.

这个钩子主要用于通知,对`git commit`的输出无影响.

### pre-rebase

这个`hook`由`git rebase`触发,可以用于避免一个分支被`rebase`.

第一个参数, the upstream the series was forked from.
第二个参数(可选), the branch being rebased (or empty when rebasing the current branch).

如果以非0状态退出,则取消`git rebase`

### post-checkout

这个`hook`由`git checkout`触发, 此时,`worktree`已经被更新.
这个`hook`接受3个参数: 之前`HEAD`的`ref`,新`HEAD`的`ref`,一个标记(1-改变分支,0-恢复文件)
这个`hook`不会影响`git checkout`的输出.

它也可以被`git clone`触发, 仅当没有使用`--no-checkout (-n)`.
第一个参数是`null-ref`,第二个参数新的`HEAD`的`ref`,第三个参数(flag)永远为1.

这个`hook`可以用于进行校验检查, 自动显示前后差异, 或者设置工作目录的`meta`属性.

### post-merge

这个`hook`由`git merge`触发,当`git pull`在本地资源库执行完毕.
这个钩子接受一个参数, 一个状态标记(当前`merge`顺利`squash`).

如果合并失败(冲突),那么这个`hook`不会影响`git merge`的输出,且不会被执行.

这个`hook`用于与`pre-commit` `hook`共同使用,以保存并恢复`working tree`的`metadata`.
(例如: `permissions`(权限)/`ownership`(所有者), `ACLS`(访问控制), `etc`).

### pre-receive

这个`hook`由远程资源库的`git-receive-pack`触发,此时,`git push`已经在本地资源库执行完毕.
此时,正准备`update`远程资源库的`refs`,且`pre-receive` `hook`已经被触发并执行完毕.
它的退出状态,决定了全部`ref`的`update`是否可以进行.

这个`hook`,每个接收操作,仅执行一次. 它不接受参数,但可以从标准输入读取以下格式的文本(每个`ref`一行):

```
  <old-value> SP <new-value> SP <ref-name> LF
```
这里的 `<old-value>` 是ref中原本的Object名,
`<new-value>` 是ref中老的Object名 and
`<ref-name>` 是ref的全名.
当创建一个新ref,`<old-value>` 将是 40, 即字符`0`.

> 注: SP=空格, LF=\n

如果这个`hook`以非0状态退出,则所有ref都不会被更新(`update`).
如果以0退出, 仍可以通过`<<update,'update'>>` `hook` 来拒绝特定的ref的更新.

`hook`的标准输入/标准输出,均导向`git send-pack`,所以,你可以简单地使用`echo`来为用户打印信息.
(译者注: 就是本地push后打印出来的信息)


### update

这个`hook`由远程资源库的`git-receive-pack`触发,此时,`git push`已经在本地资源库执行完毕.
此时,正准备`update`远程资源库的`ref`.
它的退出状态,决定了当前`ref`的`update`是否可以进行.

每个将要`update`的`ref`,都会触发一次这个`hook`, 它接受3个参数:

 - 将要被`update`的`ref`的名字,
 - `ref`中老`object`的名字,
 - 将要存储的`ref`的新名字.

以0状态退出,将允许当前`ref`被`update`.
以非0状态退出,将防止`git-receive-pack`更新当前`ref`.

这个`hook`可以用于防止特定的`ref`被`force`更新..
就是说,可以确保`fast-forward only`这一安全准则.

它也可以用于记录新旧状态.  然而, 它并不知道整体的分支状态,所以它可能被天真地用于为每个`ref`发送`email`.
`<<post-receive,'post-receive'>>` `hook`更适合做这个需求哦.

另外一个用法是使用这个`hook`实现访问控制, 而不仅仅通过文件系统的权限控制.

`hook`的标准输入/标准输出,均导向`git send-pack`,所以,你可以简单地使用`echo`来为用户打印信息.

> 注: 就是本地push后打印出来的信息

缺省的`update` `hook`, 当启用,且`hooks.allowunannotated`配置项未设置或设置为`false`时,防止未声明的`tag`被更新.


### post-receive

这个`hook`由远程资源库的`git-receive-pack`触发,此时,本地资源库的`git push`已经完成,且所有`ref`已经更新.

这个`hook`仅执行一次.  它不接受参数,但跟`<<pre-receive,'pre-receive'>>` `hook`获取相同的标准输入格式.

这个`hook`并不影响`git-receive-pack`的输出,因为它在实际工作完成之后执行.

跟`<<post-update,'post-update'>>` `hook`不一样的是,这个`hook`可以拿到`ref`在`update`前后的值.

hook的标准输入/标准输出,均导向`git send-pack`,所以,你可以简单地使用`echo`来为用户打印信息.

> 注: 就是本地`push`后打印出来的信息)

缺省的`post-receive` `hook` 是空白的, 但提供了一个示例脚本`post-receive-email`,位于源码中的`contrib/hooks`目录,实现了发送commite mails的功能.


### post-update

这个hook由远程资源库的`git-receive-pack`触发,此时,本地资源库的`git push`已经完成,且所有`ref`已经更新.

它接受可变数量的参数, 每一个参数都是已经实际`update`的`ref`的名字.

这个`hook`主要是为了统治, 无法影响`git-receive-pack`的输出.

`post-update` `hook`可以知道哪些`ref`已经被`push`,但无法知道原本及更新后的值,
所以它不是一个好地方去处理新旧变化.
`<<post-receive,'post-receive'>>` `hook` 可以拿到新旧两个值. 你可以考虑使用它们.

默认的`post-update` `hook`,启用后,将允许`git update-server-info`来更新无状态传输(例如http)的信息.
如果你通过HTTP协议来公开git资源库,那么你很可能需要启用这个hook.

`hook`的标准输入/标准输出,均导向`git send-pack`,所以,你可以简单地使用`echo`来为用户打印信息.

> 注: 就是本地push后打印出来的信息

### pre-auto-gc

这个`hook`由`git gc --auto`触发. 它不接受参数, 非0状态退出,将导致`git gc --auto`被取消.

> 注: 有一个示例contrib/hooks/pre-auto-gc-battery,演示了在电池状态(笔记本电脑没插电源)时,拒绝执行git gc的功能)

### post-rewrite

这个`hook`由改写`commit`的命令所触发(`git commit
--amend`, `git-rebase`; 当前 `git-filter-branch` 并'不'触发它!!).
它的第一个参数,表示当前是什么命令所触发:`amend` 或 `rebase`.  
也许将来会传递更多特定于命令的参数.

这个`hook`通过标准输入接收`rewritten commit`的列表,格式如下:

```
  <old-sha1> SP <new-sha1> [ SP <extra-info> ] LF
```

其中`extra-info`是命令本身所决定的,如果为空,那么前置的SP(空格)也不存在.
当前没有任何命令会使用`extra-info`.

这个`hook`总是在自动`note copying`之后只需

> 请参看 "notes.rewrite.<command>" in linkgit:git-config.txt

以下是特定命令的附加注释:

```
rebase::
	'squash' and 'fixup'操作, 所有提交(squashed)将重写进squashed commit.
	这意味着多行squash将使用同一个new-sha1'.
```

在列表中的commits的顺序,严格符合与传递给rebase的顺序.
