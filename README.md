执行方法：下载所有内容后，切换到deploy指定目录后，执行sh deploy.sh执行升级操作。
一 脚本注意事项！
①此脚本暂只适用于红帽6和红帽7系列的系统，包括CentOS6和CentOS7。
②请勿在生产系统上跑此部署脚本,因为不排除生产上面有跑需要特殊版本python环境才能跑起的生产系统，请注意！！！

二 脚本对系统存在的影响
①对系统python的环境进行修改，包括python版本、路径、pip插件、simplejson插件、setuptools插件，和需要新增一些第三方插件来支持pyvmomi（vmware提供基本python的API接口）。

三 脚本作用
1检查系统用户信息查看是否是root用户运行或其它用户运行并添加到/etc/sudoers负责退出脚本，不符合退出脚本。
2检查系统版本是否为红帽的6和7系列否则退出脚本。
3查看系统是否有安装gcc相关包，没有则退出脚本。
4查看系统是否有安装zlib和zlib-devel相关包，没有则退出脚本。
5查看系统是否有安装unzip相关包，没有则退出脚本。
6查看系统是否有安装openssl-devel相关包，没有则退出脚本。
7判断python版本是否低于2.7.10，如果低于则更新python版本到2.7.10，若失败则退出。
8安装python的setup_tools插件，若失败则退出。
9安装python的python_pip插件，若失败则退出。
10安装python的python_docopt插件，若失败则退出。
11安装python的python_simple_json插件，若失败则退出。
12安装python的pyzabbix插件，若失败则退出。
13安装python的依赖文件，若失败则退出。
14安装vmware的python接口调用程序pyvmomi，若失败则退出。


四 脚本使用方法
首先将deploy.zip压缩包解压,然后执行deploy.sh即可进行安装过程，安装过程中出现错误会自动退出，成功会提示每一个操作成功的步骤。

五 默认的日志文件存放路径和文件名为：/tmp/deploy.log 
