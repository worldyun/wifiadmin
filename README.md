<h1>中兴微随身wifi后台  WIFIAdmin</h1>

## 介绍

此版本为某些型号随身wifi设备定制版，其他型号的设备可能无法使用，相比于原版补齐了Wifi6模式选择，且增加了切卡功能。

## 使用Actions中构建的最新版本

在此仓库的Actions中有最新构建的文件，并且附带提供一键刷入脚本，只需解压至非中文路径后双击运行install.bat脚本。

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

## 刷入

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

原作者: [小白](https://github.com/Youngolo/wifiadmin) [介绍](https://www.my-youth.cn/2023/08/12/ztewechatportablewifiadmin/)