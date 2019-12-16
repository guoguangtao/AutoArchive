#! /bin/bash
# 这个文件只是用于对于多个项目，进行配置对应的路径、证书、描述文件
# 根据项目中文名称设置证书描述文件
if [ "${project_chineseName}" == "*****" ]; then
    # 测试证书
    test_code_sign_identity="Apple Distribution: *****"
    # 测试描述文件UUID
    test_provisioning_profile=*****
    # 测试开发团队
    test_development_team=*****
    # 测试打包证书名称SPECIFIER
    test_provisioning_profile_specifier=*****
    
    
    # 生产证书
    dis_code_sign_identity="Apple Distribution: ******"
    # 生产描述文件UUID
    dis_provisioning_profile=*****
    # 测试开发团队
    dis_development_team=*****
    # 测试打包证书名称SPECIFIER
    dis_provisioning_profile_specifier=*****
    
    # 项目英文缩写
    project_englishName=***
    # ipa 包名
    ipa_name=*****
    # 项目分支名称，用于 clone 项目出来
    branch_name=****
fi
