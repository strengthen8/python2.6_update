#!/bin/bash
# author: lintx
# time: 2019-05-26
# desc: ①python版本检查是否需要离线升级python2.7+,②离线安装python、pip和setuptools工具，③离线安装python依赖包④离线安装vmware官方的pyvmomi.
# usage：sh deploy.sh
# version: 1.0

source /etc/init.d/functions
USER=`whoami`
LOGFILE=/tmp/deploy.log
PYTHON_REQUIREMENT_PACKAGE=packages
PYTHON_PACKAGE=Python-2.7.10.tgz
PYTHON_INSTALL=Python-2.7.10
SETUPTOOLS_PACKAGE=setuptools-41.0.1.zip
SETUPTOOLS_VERSION=setuptools-41.0.1
PIP_PACKAGE=pip-19.1.1.tar.gz
PIP_VERSION=pip-19.1.1
DOCOPT_PACKAGE=docopt-0.6.2.tar.gz
DOCOPT_VERSION=docopt-0.6.2
SIMPLE_JSON_PACKAGE=simplejson-3.16.0.tar.gz
SIMPLE_JSON_VERSION=simplejson-3.16.0
PYVMOMI_PACKAGE=pyvmomi-master.zip
PYVMOMI_VERSION=pyvmomi-master
PY_ZABBIX_PACKAGE=py-zabbix-1.1.5.tar.gz
PY_ZABBIX_VERSION=py-zabbix-1.1.5
pip_path=/usr/local/bin/pip
python_path=/usr/local/bin/python
RETVAL=0

#step1
function get_user_info()
{
	if [ $USER == "root" ]  ||  [ `sudo cat /etc/sudoers|grep $USER|grep NOPASSWD|wc -l` -gt "0" ];then
		action "用户环境检查成功,脚本继续操作"  /bin/true
	else
		action "用户环境检查失败，脚本退出操作" /bin/false
		exit 1
	fi
}
function get_system_info()
{
	echo $CHECK_SYSTEM_VERSION_INFO >/dev/null
	if [ $RETVAL = 0 ];then
		action "系统为红帽系统,符合要求"  /bin/true
	else
		action "系统不符合要求，请使用红帽6和红帽7系列使用此脚本."  /bin/false
		exit 1
	fi
	if [ `cat /etc/redhat-release |awk -F[.] '{print $1} '|awk '{print $NF}'` -gt 5 ];then
		action "系统符合要求,为大于红帽系列6的系统版本." /bin/true
	else
		action "系统不符合要求，请使用红帽6系列系统或大于红帽6系列的系统运行此脚本." /bin/false
		exit 1
	fi
}
function get_system_rpm_info()
{
	if [ `rpm -qa|grep gcc-|grep -v libgcc|wc -l` -gt 0 ];then
		action "gcc环境正常" /bin/true
	else
		action "gcc环境缺乏,需要安装gcc的rpm包" /bin/false
		exit 1
	fi
	if [ `rpm -qa|grep zlib|wc -l` -gt 1 ];then
		action "zlib和zlib-devel环境正常"   /bin/true
	else
		action "zlib和zlib-devel环境缺乏,需要安装zlib和zlib-devel的rpm包" /bin/false
		exit 1
	fi
	if [ `rpm -qa|grep unzip|wc -l` -gt 0 ];then
		action "unzip环境正常" /bin/true
	else
		action "unzip环境缺乏,需要安unzip的rpm包" /bin/false
		exit 1
	fi
	if [ `rpm -qa|grep openssl-devel|wc -l` -gt 0 ];then
		action "openssl-devel环境正常" /bin/true
	else
		action "openssl-devel环境缺乏,需要安openssl-devel的rpm包" /bin/false
		exit 1
	fi

}
function update_python()
{
	tar xf $PYTHON_PACKAGE 2>/dev/null
	cd $PYTHON_INSTALL
	sudo ./configure --enable-optimizations >$LOGFILE  2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python更新编译configure成功"  /bin/true
	else
		action "python更新编译configure失败,请查看在/tmp/deploy.log的安装日志文件。"  /bin/false
		exit 1
	fi
	sudo make >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python更新编译make成功" /bin/true
	else
		action "python更新编译configure失败,请查看在/tmp/deploy.log的安装日志文件。" /bin/false
		exit 1
	fi
	sudo make install >> $LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python更新安装成功" /bin/true
		U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
		U_V2=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
		U_V3=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $3}'`
		sudo mv /usr/bin/python /usr/bin/python"$U_V1.$U_V2.$U_V3"
		sudo ln -s /usr/local/bin/python2.7 /usr/bin/python
	else
		action "python更新编译安装失败,输出编译日志后五十行" /bin/false
		tail -n 50 $INSTALL_PATH/deploy.log
		exit 1
	fi
	if [ `cat /etc/redhat-release |awk -F[.] '{print $1} '|awk '{print $NF}'` -eq 6 ];then
		sudo cp /usr/bin/yum /usr/bin/yum_$(date +%F)
		sudo sed -i  s/python/"python$U_V1.$U_V2.$U_V3"/g /usr/bin/yum
		echo "当前python的版本为:`python -V 2>&1`"
	fi
}
#step2
function checkPython()
{
	#推荐版本V2.7.10
	V1=2
	V2=7
	V3=10
	echo need python version is : $V1.$V2.$V3
	#获取本机python版本号.这里2>&1是必须的，python -V这个是标准错误输出的，需要转换
	U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
	U_V2=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
	U_V3=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $3}'`
	echo your python version is : $U_V1.$U_V2.$U_V3
	if [ $U_V1 -lt $V1 ];then
		echo 'Your python version is not OK!(1)'
		exit 1
	elif [ $U_V1 -eq $V1 ];then
		if [ $U_V2 -lt $V2 ];then
			update_python
		fi
	elif [ $U_V2 -eq $V2 ];then
		if [ $U_V3 -lt $V3 ];then
			update_python
		fi
	fi
	if [ `cat /etc/redhat-release |awk -F[.] '{print $1} '|awk '{print $NF}'` -eq 7 ];then
		update_python
		echo Your python version is OK!
		cd ..
	fi
}

#step3
function install_python_setup_tools()
{
	
	sudo unzip $SETUPTOOLS_PACKAGE  >/dev/null
	cd $SETUPTOOLS_VERSION
	sudo python setup.py install >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python setup-tools 安装成功!" /bin/true
		cd ..
	else
		action "python setup-tools 安装失败，请查看在/tmp/deploy.log的安装日志文件。" /bin/false
		exit 1
	fi
}

function install_python_pip()
{
	sudo tar xf  $PIP_PACKAGE  2>/dev/null
	cd $PIP_VERSION
	sudo python setup.py install >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python pip 安装成功!" /bin/true
		cd ..
	else
		action "python pip 安装失败，请查看在/tmp/deploy.log的安装日志文件。" /bin/false
		exit 1
	fi
}

function install_python_docopt()
{
	sudo tar xf  $DOCOPT_PACKAGE  2>/dev/null
	cd  $DOCOPT_VERSION/
	sudo python setup.py install  >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python docopt 安装成功!"  /bin/true
		cd ..
	else
		action "python docopt 安装失败，请查看在/tmp/deploy.log的安装日志文件。"  /bin/false
		exit 1
	fi
}

function install_python_simple_json()
{
	sudo tar xf  $SIMPLE_JSON_PACKAGE  2>/dev/null
	cd  $SIMPLE_JSON_VERSION/
	sudo python setup.py install  >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python simple_json 安装成功!"  /bin/true
		cd ..
	else
		action "python simple_json 安装失败，请查看在/tmp/deploy.log的安装日志文件。"  /bin/false
		exit 1
	fi
}

function install_python_requirements()
{
	sudo unzip packages.zip  >/dev/null
	cd $PYTHON_REQUIREMENT_PACKAGE
	sudo  $pip_path install --no-index *.whl 2>/dev/null >/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "python 依赖包 安装成功!" /bin/true
		cd ..
	else
		action "python 依赖包 安装失败，请查看在/tmp/deploy.log的安装日志文件。"   /bin/false
		exit 1
	fi
}

function install_pyzabbix()
{
	sudo tar xf  $PY_ZABBIX_PACKAGE  2>/dev/null
	cd $PY_ZABBIX_VERSION
	sudo python setup.py install  >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "pyzabbix  安装成功!" /bin/true
		cd ..
	else
		action "pyzabbix  安装失败，请查看在/tmp/deploy.log的安装日志文件。"   /bin/false
		exit 1
	fi
}

function install_pyvmomi()
{
	sudo unzip   $PYVMOMI_PACKAGE  >/dev/null
	cd  $PYVMOMI_VERSION/
	sudo $python_path setup.py install >>$LOGFILE 2>/dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		action "pyvmomi 安装成功!"  /bin/true
	else
		action "pyvmomi 安装失败，请查看在/tmp/deploy.log的安装日志文件。"  /bin/false
		exit 1
	fi
}

function main()
{
	get_user_info
	get_system_info
	get_system_rpm_info
	checkPython
	install_python_setup_tools
	install_python_pip
	install_python_docopt
	install_python_simple_json
	install_python_requirements
	install_pyzabbix
	install_pyvmomi								  
}

main
