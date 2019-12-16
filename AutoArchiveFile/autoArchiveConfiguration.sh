#! /bin/bash

# 修改当前文件的配置选项，以下的配置选项都需要核对一下

# 项目中文名称，在这里视情况而定是否需要这个变量
project_chineseName="中文名称"

# 版本号(需要修改)
version=2.2.0

# 构建版本号(需要修改)
build_version=2.2.0.1213B

# 打包模式 Debug/Release (需要修改，打包测试使用 Debug，打包上传App Store使用 Release)
archive_mode=Debug

# 登录环境
# kLoginEn_dev
# kloginEn_testB
# kloginEn_testDocker
# kloginEn_testUAT
# kLoginEn_demo
# kLoginEn_is_preRelease
# kLoginEn_is_release
loginLine=kloginEn_testB
