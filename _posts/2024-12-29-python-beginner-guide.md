---
layout: post
title: "A Python Beginner Guide for My Friend"
date: 2024-12-29 23:00:00 +0800
categories: Learning
---

**A python beginner guide for my close friends who know literally nothing about programming. Guide is written in an opinionated way. For complete tutorial of the language, just Google one.**

## 1. 基础知识

### 1.1 编程语言

编程语言是你编写程序的方式, 编程语言本身没有什么特别的魔法, 只是一种媒介, 让你可以描述你希望程序如何进行工作. 编程语言有一套固定的编写规则,
在我们写完我们的代码 (Python) 以后, 我们用对应的工具执行我们的代码, 我们的电脑会明白我们需要他做些什么, 执行我们的编写的逻辑, 输出我们要的结果.
你可以理解编程语言是专门设计来和机器/系统沟通的语言.

你可以想象成下面图片中的样子, 我们要写 Python, 我们就需要将 Python 安装到我们的电脑中.

<img src="/assets/images/python-beginner-guide/1.png" style="height: 400px" />

至于在你编写 Python 的时候, 为什么要这样写, 为什么要写这些符号, 你不用太在意这样的疑问. 因为 Python 要求你这样写, 我们就按它要求的方式编写,
Python 程序也就能理解我们在写什么, 理解了我们写什么它就能按我们要求的运行. 这背后更深的设计原因暂时先忘记, 先动手再深入.

### 1.2 操作系统

操作系统本质上就是个软件, 操作系统负责和硬件交互, 我们的电脑可以选择安装不同的操作系统, 但是本质上都是软件. 我们的 Python 代码在编写完后可以在不同的系统上运行,
这是因为不同的系统上安装的 Python 是不一样的, Python 官方自己会适配不同的操作系统. mac 上安装的是 Python mac 版, windows 上安装的是 Python windows 版,
所以绝大部分场景我们不在乎我们的脚本在什么系统上执行.

当我们希望写 Python 代码让我们的操作系统做些什么, 我们只需要按照 Python 要求我们的方式写对应的代码, 我们电脑上安装的 Python 会跟我们电脑的操作系统交互,
操作系统就会去做对应的事情. 例如, 我们希望读硬盘上的一份文件, 操作系统就会去操作硬盘, 加载这份文件的内容.

### 1.3 命令行

命令行 (windows 上叫做 Command Prompt) 本质上也就是个软件而已, 只是命令行是一种相对更专业的工具, 专门用于执行命令. 技术人员使用命令行很多时候只是因为以下几个原因：

1. 命令行更适合自动化, 例如, 写个脚本跑一大串命令 (页面不好自动点一堆按钮)
2. 缺少页面给技术人员点, 没得选, 只能跑命令
3. 喜欢命令行 (个人偏好)

## 2. 准备环境

### 2.1 安装 Python

一般来说我们不讲究 Python 的版本, 只要不是太旧就可以, 我们挑个新的版本玩也可以, 例如, 目前最新的稳定版本是 3.12.8.

如下图, 点开官方网站: [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/), 找到 `Python 3.12.8`, 点击下载 `Download Windows installer (64-bit)`。

<img src="/assets/images/python-beginner-guide/2.png" style="height: 400px" />

下载后, 打开安装包, 进行安装. 安装的过程中如果有显示 `Add Python 3.12.8 to PATH` 这样的内容, 记得将勾选框钩上.
安装完成后, 我们可以打开命令行, 验证我们的安装是否有效: 点击 Windows 的图标, 搜索并且打开 Command Prompt (命令行):

TODO: screenshot

输入 `Python`, 如果你看到显示关于 Python 版本等信息的英文, 你可以看下版本是不是我们现在装的版本 (3.12.7), 如果是, 那么恭喜你, 你成功了.
如果不是, 那么代表安装过程有点问题, 你可以重新安装, 并且确保把 `Add Python 3.12.8 to PATH` 勾选框选上.

如果你成功了, 要退出这个 Python 控制台, 输入 `exit()` 就可以退出, 效果大致如下:

```sh
~$ python3
Python 3.11.9 (main, Apr  2 2024, 08:25:04) [Clang 15.0.0 (clang-1500.3.9.4)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>>
>>>
>>>
>>>
>>> exit()
```

### 2.2 安装编辑器

对于较复杂的编程语言来说, 技术人员通常会选择较多功能的编辑器, 这类统称为 IDE (Integrated Development Environment), 可以理解成这种编辑器软件把大部分功能都塞进去了.
对于 Python 来说, 一般不太需要太 _"高级"_ 的编辑器, 推荐使用 vscode 即可. Python 本身语言较轻, 写起来比较直观, 不需要一大堆工具辅助 (不代表 Python 本身不高级, 只是不会过于不必要的复杂).

编辑器简单的来说就是个文本编辑的软件, 然后我们配套安装些插件, 插件会集成我们上面安装的 Python 从而让编辑器识别我们的代码, 我们就能有一些代码高亮, 代码文档展示, 代码编写错误提醒等基础功能.

打开 vscode 官网: [https://code.visualstudio.com/download](https://code.visualstudio.com/download), 找到 windows 版本, 下载 `x64 User Installer` 版本:

<img src="/assets/images/python-beginner-guide/3.png" style="height: 400px" />

下载后正常安装安装包, 安装后我们打开这个软件, 在左边导航栏, 选择插件页面 (如下图):

<img src="/assets/images/python-beginner-guide/4.png" style="height: 300px" />

在搜索框中搜索并且安装下图中三个插件, 这三个插件都由微软提供 (我们可以看到 Microsoft 在插件描述的下面):

<img src="/assets/images/python-beginner-guide/5.png" style="height: 200px" />

安装后, 如果 vscode 提醒的话, 重启 vscode, 至此你已经可以开始写 Python 了.

### 3. 第一个 Python 脚本

打开 vscode, 选择新建一个文本文件, 保存到你喜欢的地方, 确保命名带 `.py` 后缀, 例如: `myscript.py`:

TODO


<!--
### 3.1. 数据结构 TODO

数据结构是个专业名词, 英文是 Data Structure, 也就是设计用来装数据的结构, 因为你不是专业程序员, 不用特别专研有哪些数据结构. 不同类型的数据在取/存的时候, 使用不同的数据结构会有不同的效率, 熟练的程序员选择合适的那个数据结构最大化程序的效率.
但是就算效率低有的时候也能完成工作, 不用太在意.

数据结构本身有很多种, 有的设计特别复杂, 但基本上我们平时用得多的也就两种:

1. 数组 (本质就是一个紧凑的列表)
2. 字典 (一个 key 对应一个 value)

数组就类似于, 你把一个个空的桶放成了一排, 每个桶可以装一个东西, 数组就是这一整排的桶. 当你要往数组放东西的时候, 你可以从头开始或者从尾开始, 一个个检查看桶是不是空的, 如果不是空的就看下一个, 如果是空的, 你就可以把东西放进去.
这种一个个桶看的动作, 编程里叫做 _“遍历"_, 英文叫做 _"iterate"_. 如果这一排的桶都满了, 那么你会在这排最后一个桶后面放更多的空桶, 让这个数组变得更长, 这种操作一般称为 _"扩容“_, 因为数组的容量变大了.

字典就类似于, 在数组的基础上额外增加了份目录. 这份目录中我们给桶标了记号, 例如, 桶-A, 桶-B, 桶-C 等等等等. 通过编号你可以一下子找到桶是哪个, 你不需要一个个看. 在我们要放东西到字典前, 我们先通过固定的规则, 算出这个东西应该放哪个桶, 我们记录下来,
然后我们把这个东西放到对应的桶里. 而这个计算放在哪里的值, 我们统称为 key, 一个 key 会有对应的一个桶, 如果我们下次要找这个 key 的内容是什么, 我们可以快速基于字典的目录定位到桶, 直接拿出来.

基于这样的特征, 你也能尝试理解为什么这个数据结构被叫为字典, 因为字典就只是这样工作的: 单词有排序规则, 目录页记录单词在字典里的页码.

后面教代码的时候会有更多说明.
-->