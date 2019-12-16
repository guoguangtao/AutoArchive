#! /bin/bash

# 如果单独运行该脚本，需要配置 ipa_path(需要上传的 ipa 文件路径)、upload_file_path(上传到服务器的路径)

# 传递过来的 ipa 路径
ipa_path=$1
# 格式 /移动组/移动APP包管理/测试环境包/互生 (此处不需要加日期，后面会自动添加当前日期时间)
upload_file_path=$2

echo $ipa_path
echo $upload_file_path

# 用户名
user_name=dev

# 密码
pass_word=dev

# 服务器
host=devftp.gyist.com

# 路径
path=$upload_file_path/`date +"%Y%m%d"`
echo $path

# 创建目录
ftp -n<<!
open $host
user $user_name $pass_word
binary
hash
# 创建文件夹
mkdir $path
close
bye
!

# 上传路径
ftp_path=ftp://dev@devftp.gyist.com/$path

# 上传
curl -u $user_name:$pass_word -T $ipa_path $ftp_path/
if [ $? == 0 ]; then
    echo "\033[32m******* ipa包上传成功 *******\033[0m"
else
    echo "\033[31m******* ipa包上传失败 *******\033[0m"
fi
