## 内容目录

<!-- vim-markdown-toc GFM -->

* [SDK介绍](#sdk介绍)
    * [代码下载](#代码下载)
* [资源](#资源)
    * [阿里云物联网](#阿里云物联网)
    * [本地Samba](#本地samba)
    * [本地OpenGrok](#本地opengrok)
    * [本地分支Git](#本地分支git)
    * [乐视Jira](#乐视jira)
    * [乐视Wiki](#乐视wiki)
* [编译SDK](#编译sdk)
    * [环境需求](#环境需求)
    * [代码组织](#代码组织)
    * [编译方式](#编译方式)
        * [Ubuntu16.04编译步骤](#ubuntu1604编译步骤)
        * [Android编译步骤](#android编译步骤)
    * [输出SDK](#输出sdk)
* [样例运行](#样例运行)
    * [阿里云](#阿里云)
    * [腾讯云](#腾讯云)
    * [本地云](#本地云)
* [模块分析](#模块分析)
    * [Shadow](#shadow)
    * [MQTT](#mqtt)
    * [OTA](#ota)
* [其他](#其他)
    * [目录结构描述](#目录结构描述)
    * [维度需求](#维度需求)

<!-- vim-markdown-toc -->

----------------------------------------------------------------------------------

## SDK介绍
This is a library for smart things.

### 代码下载
  - 地址: `http://athena.devops.letv.com/#/admin/projects/smarthome/Ares`
  - 操作:

  ```bash
  git pull
  git commit -s
  git push origin HEAD:refs/for/master
  ```

  >*第一次提交会有错误提示(安装hook), 请按提示操作*

## 资源

### 阿里云物联网

[阿里云物联网](https://help.aliyun.com/product/30520.html?spm=a2c4g.11186623.3.1.aanr5b)

### 本地Samba
地址: ` smb://10.58.51.144/samba `

```
 samba
    ├── Aliyun      ---  阿里IOT离线文档
    ├── JD-joylink  ---  京东IOT离线文档
    ├── LEiot       ---  乐视IOT设计文档
    ├── Qcloud      ---  腾讯IOT离线文档
    ├── Tools       ---  工具
    └── 智能音箱    ---  Mstar智能音箱相关文档
```

### 本地OpenGrok
  地址: `http://10.58.51.144:8080/Ares/`

### 本地分支Git
  地址: ` git clone git@10.58.51.144:/git/Ares.git ` 密码: ` 1 `

### 乐视Jira
  [智能家居Jira](http://www.baidu.com)

### 乐视Wiki
  [智能家居Wiki](http://wiki.letv.cn/pages/viewpage.action?pageId=72470991)

## 编译SDK

### 环境需求
  - gcc
  - cmake 版本不低于2.8.12

### 代码组织

  代码使用cmake组织, 通过CMakeList.txt配置源码文件,编译,链接等选项.

  重要配置文件:
  ```
      .
      ├── cmake
      │   ├── CMakeLists.txt               --- 通过env.sh里面的环境变量进行平台相关配置
      │   ├── devices
      │   │   ├── gateway.cmake
      │   │   └── subdev.cmake
      │   ├── modules                      --- 实现Utils方法供cmake使用
      │   │   ├── ConfigPreAndPost.cmake
      │   │   ├── DownloadCodes.cmake
      │   │   ├── InternalFuncs.cmake
      │   │   └── SetEnv.cmake
      │   └── platforms                    --- 根据环境变量OS_PLATFORM选着平台配置文件
      │       ├── android.cmake
      │       ├── iOS.cmake
      │       └── ubuntu.cmake
      ├── CMakeLists.txt                   --- 顶级CMakeLists.txt
      ├── doc
      │   ├── aliyun
      │   └── sample-log
      ├── external                         --- 第三方源码下载目录
      │   ├── CMakeLists.txt               --- 实现下载编译第三方代码的CMakeList.txt
      │   ├── mbedtls
      │   └── paho.mqtt.embedded-c
      ├── sample                           --- 编译Sample
      │   ├── CMakeLists.txt
      │   ├── coap
      │   ├── device-shadow
      │   │   └── CMakeLists.txt
      │   ├── http
      │   ├── mqtt
      │   │   └── CMakeLists.txt
      │   ├── ota
      │   └── subdev
      │       └── CMakeLists.txt
      ├── script                           --- 脚本Utils
      └── src
          ├── CMakeLists.txt               --- IOT SDK编译配置总控, 搜集子模块源文件或库文件
          .
          .
          .
          ├── mqtt-client
          │   └── CMakeLists.txt
          ├── ota
          │   └── CMakeLists.txt
          ├── platform
          │   ├── CMakeLists.txt           --- 根据OS_PLATFORM选择os/${OS_PLATFORM}子目录编译
          │   ├── os
          │   │   ├── android
          │   │   ├── ubuntu
          │   │   └── win7
          │   └── ssl
          │       ├── mbedtls
          │       └── openssl
          .
          .
          .
          └── utils
              ├── CMakeLists.txt
              ├── digest
              ├── log
              └── misc
  ```

### 编译方式

#### Ubuntu16.04编译步骤

1. 修改env.sh

  ```bash
  export ENABLE_DEBUG=ON
  export OS_PLATFORM=ubuntu
  ```

2. 执行

  ```bash
      source env.sh
      mkdir output
      cd output
      cmake ..
      make
  ```


#### Android编译步骤

Android平台Standalone Toolchains [官方文档](https://developer.android.com/ndk/guides/standalone_toolchain.html)

1. 下载最新版本NDK

  [官网下载](https://developer.android.google.cn/ndk/downloads/index.html)

2. 确定自己Android平台的架构ARCH 和 Android API Level
  - 可以通过在Android源码环境中执行`printconfig`输出目标平台配置
  - 从Android源码`build/core/version_plaform.mk`文件获取SDK版本号, 搜索`PLATFORM_VERSION`

  > *如果编译过程是由于编译选项造成编译不过, 可以在Android源码执行`mm -n`,查看系统默认打开的选项.*

  例如`mstar648`配置信息:

      TARGET_ARCH=arm64
      PLATFORM_VERSION := 6.0
      PLATFORM_SDK_VERSION := 23

3. 根据上一步的信息, 配置`cmake/platforms/{{OS_PLATFORM}.cmake`, 例如648平台:
  ```
  SET (ANDROID_API "23")
  SET (ANDROID_ARCH "arm64")
  SET (CROSS_PREFIX "aarch64-linux-android-")
  ```
  > *设置后第一次编译会根据这些信息生成sysroot*

4. 修改`env.sh`, 设置NDK的安装路径, 即`ndk_build`所在目录, 例如:

  ```bash
  export NDK_DIR=/opt/ndk
  export PATH=${NDK_DIR}:$PATH

  export ENABLE_DEBUG=ON
  export OS_PLATFORM=android
  ```

5. 修改`cmake/platforms/${OS_PLATFORM}.cmake`, 指定"-fPIE -pie"等必要选项:

  ```cmake
  LIST (APPEND PLATFORM_CFLAGS
      "-Wall"
      "-g3"
      "-rdynamic"
      "-fPIE"
      "-pie"
      )

  # LDFLAG: linked flags
  LIST (APPEND PLATFORM_LDFLAGS
      "-fPIE"
      "-pie"
      )

  # LIB: dynamic platform libraries
  LIST (APPEND PLATFORM_SHARED_LIBS
      "android"
      "log"
      )
  ```

6. 根据自己的平台判断是否需要实现或修改HAL层代码, 比如`ALOG`

  ```
  src/platform/os/${OS_PLATFORM}/HAL_OS_${OS_PLATFORM}.c
  src/platform/os/${OS_PLATFORM}/HAL_TCP_${OS_PLATFORM}.c
  src/platform/os/${OS_PLATFORM}/HAL_UDP_${OS_PLATFORM}.c
  ```

7. 执行, 第一次执行可能会很慢, 自动生成sysroot编译环境以及下载第三放库源码

  ```bash
  source env.sh
  mkdir output
  cd output
  cmake ..
  make
  ```

### 输出SDK
  在output目录执行
  ```bash
    make sdk_package
  ```
  会在当前路径下生成一个Release包`sdk_package.x.x.x.tar.gz`, 其中包含工程编译出的库和对外头文件

  ```
     sdk_package
     ├── bin
     │   ├── mqtt_rrpc-example
     │   ├── shadow-control-example
     │   ├── shadow-example
     │   └── subdev-example
     ├── include
     │   ├── exports
     │   │   ├── iot_export_coap.h
     │   │   ├── iot_export_errno.h
     │   │   ├── iot_export_http.h
     │   │   ├── iot_export_mqtt.h
     │   │   ├── iot_export_ota.h
     │   │   ├── iot_export_shadow.h
     │   │   └── iot_export_subdev.h
     │   ├── imports
     │   │   ├── iot_import_coap.h
     │   │   ├── iot_import_config.h
     │   │   ├── iot_import_dtls.h
     │   │   └── iot_import_ota.h
     │   ├── iot_export.h
     │   ├── iot_import.h
     │   └── sdk-impl_internal.h
     └── lib
         ├── libleiot_platform.a
         ├── libleiot_sdk.a
         ├── libleiot_utils.a
         ├── libmbedtls.a
         └── libMQTTPacketClient.a
  ```

## 样例运行

### 阿里云
修改`env.sh`
```bash
export CLOUD_SERVER="ali"
```
### 腾讯云
修改`env.sh`
```bash
export CLOUD_SERVER="tencent"
```

### 本地云
修改`env.sh`
```bash
export CLOUD_SERVER="local"
export LOCAL_CLOUD_HOST=10.58.51.144
export LOCAL_CLOUD_PORT=1883
```
## 模块分析

### Shadow
See `doc/nodes/Shadow.md`

### MQTT
TODO

### OTA
TODO

## 其他
### 目录结构描述
```
  +-- sample                  : 例程目录, 演示通信模块和服务模块的使用
  +-- src
      +-- sdk-impl            : SDK的接口层, 提供总体的头文件, 和一些API的接口封装
      +-- sdk-tests           : SDK的单元测试
      +-- mqtt-client         : 通信模块, 实现以MQTT协议接入[和云讨论]
      +-- udp-client          : 通信模块, 实现以udp局域网协议接入<制定标准后通知APP>
      +-- tcp-client          : 通信模块, 实现以tcp协议接入[备选，有限级低，可能代替MQTT]
      +-- ota                 : 服务模块, 实现固件下载通道[参考电视，找OO谈]
      +-- shadow              : 服务模块, 实现设备影子
      +-- platform            : 硬件平台抽象层, 存放不同嵌入式设备的抽象层接口实现, 支撑以上模块形成跨平台
      +-- import              : 外部输入目录, 存放芯片/模组厂商提供的头文件/二进制库
      +-- access              : 实现不同配网方式，包括：softAP, 一件配网， 批量配网等
      +-- security            : 实现设备安全认证
      +-- system              : 基础模块, 实现全局信息保存, 如预置的设备标识ID等
      +-- tls                 : 基础模块, 实现TLS/DTLS, 来自裁剪过的开源软件mbedtls
```
### 维度需求
1. 资源总成，生成最终的SDK（一个静态库）
2. Debug版&release版
3. 各自模块子makefile
4. Linux编译环境
5. SDK独立编译环境不和Android编译环境集成（只提交静态库）
6. 代码不依赖Android资源
7. 针对不同设备类型输出不同SDK（中控，standlone设备，网关等）
8. 针对不同目标平台（Linux，Android，FreeRTOS，无操作系统）
