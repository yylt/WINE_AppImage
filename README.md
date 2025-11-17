## Wine AppImage 使用指南

本文档介绍如何使用 Wine AppImage 在 Linux 系统上安装和运行 Windows 应用程序。

## 概述

Wine AppImage 是一个打包成 AppImage 格式的 Wine 兼容层，它让您无需复杂配置即可在 Linux 系统中运行 Windows 应用程序。此版本已启用 WOW64 支持，可同时运行 32 位和 64 位 Windows 程序。

## 系统要求

- Linux 操作系统

- 安装 fonts-noto-cjk 字体，用于显示中文

## 使用步骤

1. 下载 Wine AppImage


从以下地址下载最新的 Wine AppImage：

```
https://github.com/mmtrt/WINE_AppImage/

如
https://ghfast.top/github.com/mmtrt/WINE_AppImage/releases/download/continuous-staging/wine-staging_10.19-x86_64.AppImage
```

下载完成后，赋予执行权限, 并移动到 /usr/local/bin 目录下

```
chmod +x wine-*.AppImage
sudo mv wine-*.AppImage /usr/local/bin/wine-staging.AppImage
```

2. 初始化和安装 Wine-Mono

Wine-Mono 是 .NET Framework 的兼容实现，许多 Windows 应用程序需要它。

执行以下命令进行初始化：
```bash

wine-staging.AppImage
```

然后安装 Wine-Mono：

```bash
wine-staging.AppImage ~/.cache/wine/wine-mono*.msi
```

3. 安装 Windows 应用程序

下载 Windows 应用程序的安装程序或安装包，例如 .exe 文件或 .msi 文件。

执行以下命令安装应用程序，安装完成后，建议不要直接启动，由桌面文件启动

```bash
wine-staging.AppImage setup.exe
```

4. 安装桌面文件和图标

执行应用程序目录下的 apps/install_apps.sh 脚本，将创建桌面启动器和应用程序图标，当前只支持企业微信

```bash
bash apps/install_apps.sh
```

## 常用命令

打开 Wine 配置

```bash
wine-staging.AppImage winecfg
```

打开注册表编辑器

```bash
wine-staging.AppImage regedit
```

运行 Windows 命令行

```bash
wine-staging.AppImage cmd
```

运行 Windows Explorer

```bash
wine-staging.AppImage explorer
```
