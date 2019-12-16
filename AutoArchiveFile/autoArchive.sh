#！/bin/bash

# 获取当前路径
current_dir=$(cd `dirname $0`; pwd)
echo $current_dir

# 引用 打包配置文件
. ${current_dir}/autoArchiveConfiguration.sh

# 项目证书、描述文件配置
. ${current_dir}/codeSignProvisiongProfile.sh

# project.pbxproj DebugKey
# 这个 key 在 project.pbxproj 文件中，项目证书和描述文件 Debug Key，通过手动设置证书和描述文件之后，然后打开 project.pbxproj 搜索配置的描述文件名，可以获取到这个key，因为项目都是同一个项目，所以这个 key 都是一样的
project_pbxproj_debug_key=0388E55D21194FAC008CF5EE

# project.pbxproj ReleaseKey
# 这个 key 在 project.pbxproj 文件中，项目证书和描述文件 Release Key
project_pbxproj_release_key=0388E55E21194FAC008CF5EE

# 工程名
project_name=工程名

# scheme名
scheme_name=scheme

# exportOptions.plist 文件路径
export_options_list_type=dev
if [ "$archive_mode" == "Debug" ]; then
    # 配置测试环境 exportOptions.plist
    export_options_list_type=adHoc;
    # 配置测试环境证书
    CODE_SIGN_IDENTITY=${test_code_sign_identity}
    # 配置测试环境描述文件
    PROVISIONING_PROFILE=${test_provisioning_profile}
    # 打包Team
    development_team=${test_development_team}
    # 打包描述文件名称
    provisioning_profile_specifier=${test_provisioning_profile_specifier}
    # 包名
    ipa_name=${ipa_name}_${build_version}
    # 是否生产环境
    isReleaseEn=NO
    # 上传路径
    upload_file_path=/移动组/移动APP包管理/测试环境包/$project_chineseName
else
    # 配置生产环境 exportOptions.plist
    export_options_list_type=dis;
    # 配置生产环境证书
    CODE_SIGN_IDENTITY=${dis_code_sign_identity}
    # 配置生产环境描述文件
    PROVISIONING_PROFILE=${dis_provisioning_profile}
    # 打包Team
    development_team=${dis_development_team}
    # 打包描述文件名称
    provisioning_profile_specifier=${dis_provisioning_profile_specifier}
    # 包名
    ipa_name=${ipa_name}_${build_version}_release
    # 是否是生产环境
    isReleaseEn=YES
    # 上传路径
    upload_file_path=/移动组/移动APP包管理/生产环境包/$project_chineseName
fi

# 根据打包模式，选择 exportOptions.plist 文件
export_options_list_path=${current_dir}/ExportOptions/ExportOptions_${project_englishName}_${export_options_list_type}.plist

# 创建文件夹
if [ ! -d ${current_dir}/IPADir/${project_chineseName} ]; then
    mkdir -p ${current_dir}/IPADir/${project_chineseName};
fi

# 导出 .ipa 文件所在路径
ipa_date_path=`date +%Y%m%d%H%M%S`
ipa_path=${current_dir}/IPADir/$project_chineseName/$ipa_date_path/
mkdir $ipa_path # 创建IPA存放路径

# archive存放路径
archive_path=$ipa_path/${project_name}.xcarchive

# clone 工程目录
project_path=$ipa_path

# 进入工程目录进行操作
cd ${project_path}
# 克隆代码

# 克隆代码
git clone -b 分支名称 项目代码地址

if [ $? != 0 ]; then
    echo "\033[31m****** 克隆代码出错 ******\033[0m"
    exit
else
    echo "\033[32m****** 克隆代码成功 ******\033[0m"
fi


# 工程目录真正的路径
project_path=$project_path/$project_name

# 进入工程目录
cd $project_path

# 工作空间
workspace_path=${project_path}/${project_name}.xcworkspace

# Info.plist 文件路径
info_plist_path=${project_path}/${project_name}/Info.plist

# pod 更新
if [ -e ./Podfile.lock ]; then
    echo "\033[32m****** 存在 Podfile.lock文件 ******\033[0m"
    rm -rf ./Podfile.lock
else
    echo "\033[31m****** 不存在 Podfile.lock文件 ******\033[0m"
fi
echo "****** 更新Pod *******"
# 更新pod
pod install

if [ $? != 0 ]; then
    echo "\033[31m****** 更新 Pod 失败 ******\033[0m"
    exit
else
    echo "\033[32m****** 更新 Pod 成功 ******\033[0m"
fi

# 修改环境

# appdelegate路径
appdelegate_path=${project_path}/$project_name/GYAppDelegate.m

# 修改登录环境变量
sed -i -r "s/\[GYHSLoginManager shareInstance\].loginLine.*\$/[GYHSLoginManager shareInstance].loginLine = $loginLine;/g" $appdelegate_path;

if [ $? == 0 ]; then
    echo "\033[32m****** 修改登录环境成功 ******\033[0m"
else
    echo "\033[31m****** 修改登录环境失败 ******\033[0m"
    exit
fi

# 修改是否生产环境变量
sed -i -r "s/\/\/.*\[GYHSLoginManager shareInstance\].isReleaseEn.*\$/[GYHSLoginManager shareInstance].isReleaseEn = $isReleaseEn;/g" $appdelegate_path;
sed -i -r "s/\[GYHSLoginManager shareInstance\].isReleaseEn.*\$/[GYHSLoginManager shareInstance].isReleaseEn = $isReleaseEn;/g" $appdelegate_path;

if [ $? == 0 ]; then
    echo "\033[32m****** 修改 isReleaseEn 变量成功 ******\033[0m"
else
    echo "\033[31m****** 修改 isReleaseEn 变量失败 ******\033[0m"
    exit
fi

# 删除 -r 文件
if [ -e $appdelegate_path-r ]; then
    echo "\033[34m******* 存在 $appdelegate_path-r 文件"
    rm -rf $appdelegate_path-r
fi

# 修改版本号
/usr/libexec/PlistBuddy -c "set CFBundleShortVersionString $version" $info_plist_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改版本号失败 ******\033[0m"
else
    echo "\033[32m****** 修改版本号成功 ******\033[0m"
fi

# 修改build
/usr/libexec/PlistBuddy -c "set CFBundleVersion $build_version" $info_plist_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改build号失败 ******\033[0m"
else
    echo "\033[32m****** 修改Build号成功 ******\033[0m"
fi

# 修改证书
# project.pbxproj 路径
project_pbxproj_path=${project_path}/${project_name}.xcodeproj/project.pbxproj

# 修改证书描述文件 第一种方式
#sed -i -r 's/PROVISIONING_PROFILE_SPECIFIER.*$/PROVISIONING_PROFILE_SPECIFIER = hsxt_AdHoc;/g' $project_pbxproj_path

# 修改证书描述文件 第二种方式
# 修改Debug证书
/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_debug_key}:buildSettings:CODE_SIGN_IDENTITY iPhone Distribution" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Debug签名失败 ******\033[0m"
else
    echo "\033[32m****** 修改Debug签名成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_debug_key}:buildSettings:CODE_SIGN_IDENTITY[sdk=iphoneos*] iPhone Distribution" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改DebugSDK签名失败 ******\033[0m"
else
    echo "\033[32m****** 修改DebugSDK签名成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_debug_key}:buildSettings:DEVELOPMENT_TEAM ${development_team}" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Debug DEVELOPMENT_TEAM 失败 ******\033[0m"
else
    echo "\033[32m****** 修改Debug DEVELOPMENT_TEAM 成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_debug_key}:buildSettings:PROVISIONING_PROFILE_SPECIFIER ${provisioning_profile_specifier}" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Debug描述文件失败 ******\033[0m"
else
    echo "\033[32m****** 修改Debug描述文件成功 ******\033[0m"
fi

# 修改Release证书
/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_release_key}:buildSettings:CODE_SIGN_IDENTITY iPhone Distribution" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Release签名失败 ******\033[0m"
else
    echo "\033[32m****** 修改Release签名成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_release_key}:buildSettings:CODE_SIGN_IDENTITY[sdk=iphoneos*] iPhone Distribution" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改ReleaseSDK签名失败 ******\033[0m"
else
    echo "\033[32m****** 修改ReleaseSDK签名成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_release_key}:buildSettings:DEVELOPMENT_TEAM ${development_team}" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Release DEVELOPMENT_TEAM 失败 ******\033[0m"
else
    echo "\033[32m****** 修改Release DEVELOPMENT_TEAM 成功 ******\033[0m"
fi

/usr/libexec/PlistBuddy -c "set :objects:${project_pbxproj_release_key}:buildSettings:PROVISIONING_PROFILE_SPECIFIER ${provisioning_profile_specifier}" $project_pbxproj_path

if [ $? != 0 ]; then
    echo "\033[31m****** 修改Release描述文件失败 ******\033[0m"
else
    echo "\033[32m****** 修改Release描述文件成功 ******\033[0m"
fi

echo "******* 开始 clean 工程 ********"
# clean 工程
xcodebuild clean \
-workspace ${workspace_path} \
-scheme ${scheme_name} \
-configuration ${archive_mode} \
-quiet
echo "\033[32m******** clean 工程完毕 ********\033[0m"

echo "******* 开始打包 ********"
# 打包
xcodebuild archive \
-workspace ${workspace_path} \
-scheme ${scheme_name} \
-configuration ${archive_mode} \
-archivePath ${archive_path} \
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" \
-quiet

if [ -e ${ipa_path}/${scheme_name}.xcarchive ]; then
    echo '\033[32m****** 打包成功 *****\033[0m'
else
    echo "\033[31m****** 打包失败 *****\033[0m"
        rm -rf ${ipa_path}
    exit
fi

echo "******* 开始导出ipa包 ********"
# 导出ipa包
xcodebuild -exportArchive \
-archivePath ${archive_path} \
-exportPath ${ipa_path} \
-exportOptionsPlist ${export_options_list_path} \
-quiet

if [ -e ${ipa_path}/${scheme_name}.ipa ]; then
    echo '\033[32m***** ipa包导出成功 *****\033[0m'
else
    echo "\033[31m***** ipa包导出失败 *****\033[0m"
    exit
fi

mv ${ipa_path}/${scheme_name}.ipa ${ipa_path}/${ipa_name}.ipa

if [ $? != 0 ]; then
    echo "\033[31m****** 修改包名 ${ipa_name}.ipa 失败 ******\033[0m"
else
    echo "\033[32m****** 修改包名 ${ipa_name}.ipa 成功 ******\033[0m"
fi

# 移除 .xcarchive 文件
rm -rf ${ipa_path}/${scheme_name}.xcarchive
# 移除 DistributionSummary.plist 文件
rm -rf ${ipa_path}/DistributionSummary.plist
# 移除 ExportOptions.plist 文件
rm -rf ${ipa_path}/ExportOptions.plist
# 移除 Packaging.log 文件
rm -rf ${ipa_path}/Packaging.log
# 移除项目工程文件
rm -rf $ipa_path/$project_name

if [ $? == 0 ]; then
    echo "\033[32m****** 删除工程目录文件成功 ******\033[0m"
else
    echo "\033[31m****** 删除工程目录文件失败 ******\033[0m"
fi
 
# 移除 GYCompany 工程文件
rm -rf $ipa_path/GYCompany
# 移除 GYPrdExpand 工程文件
rm -rf $ipa_path/GYPrdExpand


# 文件上传
. ${current_dir}/uploadFile.sh ${ipa_path}/${ipa_name}.ipa $upload_file_path

