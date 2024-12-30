---
layout: post
title:  "A Python Beginner Guide for My Friend"
date:   2024-12-29 23:00:00 +0800
categories: Learning
---

**A python beginner guide for my close friends who know literally nothing about programming. Guide is written in an opinionated way. For complete tutorial of the language, just Google one.**

## 1. 基础知识

### 编程语言

编程语言是你编写程序的方式, 编程语言本身没有什么特别的魔法, 只是一种媒介, 让你可以描述你希望程序如何进行工作. 编程语言有一套固定的编写规则,
在我们写完我们的代码 (Python) 以后, 我们用对应的工具执行我们的代码, 我们的电脑会明白我们需要他做些什么, 执行我们的编写的逻辑, 输出我们要的结果.
你可以理解编程语言是专门设计来和机器/系统沟通的语言.

你可以想象成下面图片中的样子, 我们要写 Python, 我们就需要将 Python 安装到我们的电脑中.

<img src="/assets/images/python-beginner-guide/1.png" style="height: 400px" />

至于在你编写 Python 的时候, 为什么要这样写, 为什么要写这些符号, 你不用太在意这样的疑问. 因为 Python 要求你这样写, 我们就按它要求的方式编写,
Python 程序也就能理解我们在写什么, 理解了我们写什么它就能按我们要求的运行. 这背后更深的设计原因暂时先忘记, 先动手再深入.

### 操作系统

操作系统本质上就是个软件, 操作系统负责和硬件交互, 我们的电脑可以选择安装不同的操作系统, 但是本质上都是软件. 我们的 Python 代码在编写完后可以在不同的系统上运行,
这是因为不同的系统上安装的 Python 是不一样的, Python 官方自己会适配不同的操作系统. mac 上安装的是 Python mac 版, windows 上安装的是 Python windows 版,
所以绝大部分场景我们不在乎我们的脚本在什么系统上执行.

当我们希望写 Python 代码让我们的操作系统做些什么, 我们只需要按照 Python 要求我们的方式写对应的代码, 我们电脑上安装的 Python 会跟我们电脑的操作系统交互,
操作系统就会去做对应的事情. 例如, 我们希望读硬盘上的一份文件, 操作系统就会去操作硬盘, 加载这份文件的内容.

### 命令行

命令行 (windows 上叫做 Command Prompt) 本质上也就是个软件而已, 只是命令行是一种相对更专业的工具, 专门用于执行命令. 技术人员使用命令行很多时候只是因为以下几个原因：

1. 命令行更适合自动化, 例如, 写个脚本跑一大串命令 (页面不好自动点一堆按钮)
2. 缺少页面给技术人员点, 没得选, 只能跑命令
3. 喜欢命令行 (个人偏好)

## 2. 准备环境

### 安装 Python

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




