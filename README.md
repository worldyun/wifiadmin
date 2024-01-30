<h1>中兴微随身wifi后台  WIFIAdmin</h1>

## 介绍

此版本为某些型号随身wifi设备定制版，其他型号的设备可能无法使用，相比于原版补齐了Wifi6模式选择，增加了切卡功能，删除了一些不需要的功能。

## 使用Actions中构建的最新版本

在此仓库的Actions中有最新构建的文件，并且附带提供一键刷入脚本，只需解压至非中文路径后双击运行install.bat脚本。在刷入前，请确保电脑中安装有ADB，且配置了环境变量。

注意：Actions中的文件不会永久保存，一定时间后会被删除，此仓库不提供Releases版本，请自行构建。

## 自行构建
### 环境准备：
- node.js 
- npm 

### 构建

- 拉取代码

```powershell
git clone https://github.com/worldyun/wifiadmin.git
```

- 安装pnpm包管理器

```powershell
cd wifiadmin
npm install -g pnpm
```

- 安装依赖

```powershell
pnpm install
```

- 构建

```powershell
pnpm build
```

## 使用一键脚本刷入

- 在刷入前，请确保电脑中安装有ADB，且配置了环境变量。

- 构建后的文件在项目目录的dist文件夹中，一键刷入脚本在doc文件夹中。

- 将dist文件夹重命名为web文件夹，且将install.bat文件置于web文件夹同级。如下：

```
非中文路径
  |
  |—— install.bat
  |—— web
      |
      |—— assets
      |—— static
  ... 
  ...
```

- 运行install.bat脚本，根据提示刷入。

## 手动刷入

以下内容来自[jqtmviyu/wifiadmin](https://github.com/jqtmviyu/wifiadmin)

### 备份(可选)

```sh
# 自己修改备份路径
adb pull /etc_rc/web ../web_backup
```

### 替换

```sh
# 重新挂载可读
adb shell mount -o remount,rw /
# 删除旧web
adb shell rm -rf /etc_ro/web/*
# 上传
adb push ./dist/* /etc_ro/web/
# 重启
adb shell reboot
```

## 其他

这是一些可选操作，根据实际情况选择是否使用。

### 去云控开锁频

```sh
adb shell mount -o remount,rw /
adb shell nv set mqtt_host=127.0.0.1
adb shell nv set fota_updateMode=0
adb shell nv set os_url=http://127.0.0.1/
adb shell nv set lpa_trigger_host=127.0.0.1
adb shell nv set safecare_hostname=http://127.0.0.1/
adb shell nv set safecare_mobsite=http://127.0.0.1/
adb shell nv set band_select_enable=1
adb shell nv set dns_manual_func_enable=1
adb shell nv set tr069_func_enable=1
adb shell nv set ussd_enable=1
adb shell nv save
```

### 用 ADB 命令切卡

```sh
adb shell mount -o remount,rw /
adb shell chmod 000 /bin/P2x
adb shell nv set sim_switch=0
adb shell nv save
```

原作者: [小白](https://github.com/Youngolo/wifiadmin) [介绍](https://www.my-youth.cn/2023/08/12/ztewechatportablewifiadmin/)