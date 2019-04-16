#!/bin/bash
## env:
## CentOS Linux 7 (AltArch)	--7.5.1804
## Linux localhost 4.14.15-6.hxt.aarch64 #1 SMP Tue Apr 10 08:55:00 UTC 2018 aarch64 aarch64 aarch64 GNU/Linux
## user: root
## at lease 25G free space for all version compile

## java-1.7.0 java-1.8.0 jdk8u-server-release-1804
## jdk8u-server-release-1804 compile hadoop 2.8.x 2.9.x 3.x have error: [ERROR] Plugin org.apache.maven.plugins:maven-site-plugin:3.5 or one of its dependencies could not be resolved: Failed to read artifact descriptor for org.apache.maven.plugins:maven-site-plugin:jar:3.5: Could not transfer artifact org.apache.maven.plugins:maven-site-plugin:pom:3.5 from/to central (https://repo.maven.apache.org/maven2): java.lang.RuntimeException: Unexpected error: java.security.InvalidAlgorithmParameterException: the trustAnchors parameter must be non-empty -> [Help 1] 
DEF_JAVA="java-1.8.0"
CURRENTPATH=$PWD
TESTFOLDWEPRE=$CURRENTPATH/testcase

## required CentOS RPMs: http://mirror.centos.org/altarch/7.5.1804/os/aarch64/Packages
yum install -y svn ncurses-devel lzo-devel zlib-devel autoconf automake libtool cmake openssl-devel snappy snappy-devel bzip2-devel java-1.8.0-openjdk* java-1.7.0-openjdk* gcc* protobuf* wget vim tree

## require ssh...
if [ ! -e "$HOME/.ssh/authorized_keys" ] ; then
  isContinue='y'
  echo "please run following command in other terminal..."
  echo "ssh root@localhost"
  echo "cd ~/.ssh/"
  echo "ssh-keygen -t rsa"
  echo "cat ./id_rsa.pub >> ./authorized_keys"
  echo "chmod 600 ./authorized_keys"
  read -p 'Done and press anykey to continue...' isContinue
  echo ${isContinue}
  if [ ! -e "$HOME/.ssh/authorized_keys" ] ; then
    echo "please run above commands!"
    exit -1;
  fi
fi

## http://mirror.centos.org/altarch/7.5.1804/os/aarch64/Packages/protobuf-2.5.0-8.el7.aarch64.rpm
## http://mirrors.ustc.edu.cn/apache/maven/maven-3/3.3.9/binaries
if [ ! -e "apache-maven-3.3.9-bin.tar.gz" ] ; then
  echo "download hadoop apache-maven-3.3.9..."
  wget http://mirrors.ustc.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
fi
if [ ! -e "/usr/local/apache-maven-3.3.9" ] ; then
  tar -zxvf apache-maven-3.3.9-bin.tar.gz -C /usr/local
fi
## https://archive.apache.org/dist/ant/binaries
if [ ! -e "apache-ant-1.9.4-bin.tar.gz" ] ; then
  echo "download hadoop apache-ant-1.9.4..."
  wget https://archive.apache.org/dist/ant/binaries/apache-ant-1.9.4-bin.tar.gz
fi
if [ ! -e "/opt/apache-ant-1.9.4" ] ; then
  tar -zxvf apache-ant-1.9.4-bin.tar.gz -C /opt
fi
## http://findbugs.sourceforge.net/downloads.html
if [ ! -e "findbugs-3.0.1.tar.gz" ] ; then
  echo "download hadoop findbugs-3.0.1..."
  wget https://sourceforge.net/projects/findbugs/files/findbugs/3.0.1/findbugs-3.0.1.tar.gz
fi
if [ ! -e "/opt/findbugs-3.0.1" ] ; then
  tar -zxvf findbugs-3.0.1.tar.gz -C /opt
fi
## https://cmake.org/files/v3.11/cmake-3.11.3.tar.gz
## without high cmake, hadoop 3.0.2 common maybe compile error.
if [ ! -e "cmake-3.11.3.tar.gz" ] ; then
  echo "download hadoop cmake-3.11.3..."
  wget https://cmake.org/files/v3.11/cmake-3.11.3.tar.gz
fi
if [ ! -e "/usr/local/bin/cmake" ] ; then
  if [ -e "cmake-3.11.3" ] ; then
    rm -rf cmake-3.11.3
  fi
  tar -zxvf cmake-3.11.3.tar.gz
  cd cmake-3.11.3
  ./configure
  make
  make install
  cd -
fi

## linaro jdk is optimized and hadoop will have good performance
if [ ! -e "jdk8u-server-release-1804.tar.xz" ] ; then
  wget http://openjdk.linaro.org/releases/jdk8u-server-release-1804.tar.xz
fi
if [ ! -e "/usr/lib/jvm/jdk8u-server-release-1804" ] ; then
  xz -dkf jdk8u-server-release-1804.tar.xz
  tar -xf jdk8u-server-release-1804.tar -C /usr/lib/jvm
fi
## if have free time, better to get source then compile them or get rpm


## hadoop 2.6.5 require java-1.7.0; hadoop-2.7.6 and higher version require java-1.8.0
## ll /usr/lib/jvm/
## java -> /etc/alternatives/java_sdk
## java-1.7.0 -> /etc/alternatives/java_sdk_1.7.0
## java-1.7.0-openjdk -> /etc/alternatives/java_sdk_1.7.0_openjdk
## java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64
## java-1.8.0 -> /etc/alternatives/java_sdk_1.8.0
## java-1.8.0-openjdk -> /etc/alternatives/java_sdk_1.8.0_openjdk
## java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64-debug
## java-openjdk -> /etc/alternatives/java_sdk_openjdk
## jre -> /etc/alternatives/jre
## jre-1.7.0 -> /etc/alternatives/jre_1.7.0
## jre-1.7.0-openjdk -> /etc/alternatives/jre_1.7.0_openjdk
## jre-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64 -> java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64/jre
## jre-1.8.0 -> /etc/alternatives/jre_1.8.0
## jre-1.8.0-openjdk -> /etc/alternatives/jre_1.8.0_openjdk
## jre-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64 -> java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/jre
## jre-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64-debug -> java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64-debug/jre
## jre-openjdk -> /etc/alternatives/jre_openjdk
##
## ll /etc/alternatives/java*
## /etc/alternatives/java -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/jre/bin/java
## /etc/alternatives/java.1.gz -> /usr/share/man/man1/java-java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64.1.gz
## /etc/alternatives/javac -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/bin/javac
## /etc/alternatives/javac.1.gz -> /usr/share/man/man1/javac-java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64.1.gz
## /etc/alternatives/javadoc -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/bin/javadoc
## /etc/alternatives/javadoc.1.gz -> /usr/share/man/man1/javadoc-java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64.1.gz
## /etc/alternatives/javadocdir -> /usr/share/javadoc/java-1.8.0-openjdk-1.8.0.171-7.b10.el7/api
## /etc/alternatives/javadoczip -> /usr/share/javadoc/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.zip
## /etc/alternatives/javah -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/bin/javah
## /etc/alternatives/javah.1.gz -> /usr/share/man/man1/javah-java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64.1.gz
## /etc/alternatives/javap -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64/bin/javap
## /etc/alternatives/javap.1.gz -> /usr/share/man/man1/javap-java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64.1.gz
## /etc/alternatives/java_sdk -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_1.7.0 -> /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64
## /etc/alternatives/java_sdk_1.7.0_exports -> /usr/lib/jvm-exports/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64
## /etc/alternatives/java_sdk_1.7.0_openjdk -> /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64
## /etc/alternatives/java_sdk_1.7.0_openjdk_exports -> /usr/lib/jvm-exports/java-1.7.0-openjdk-1.7.0.181-2.6.14.5.el7.aarch64
## /etc/alternatives/java_sdk_1.8.0 -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_1.8.0_exports -> /usr/lib/jvm-exports/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_1.8.0_openjdk -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_1.8.0_openjdk_exports -> /usr/lib/jvm-exports/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_exports -> /usr/lib/jvm-exports/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_openjdk -> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64
## /etc/alternatives/java_sdk_openjdk_exports -> /usr/lib/jvm-exports/java-1.8.0-openjdk-1.8.0.171-7.b10.el7.aarch64


#################################################################################################
## hadoop_env(jdk version)
#################################################################################################
hadoop_env(){
## set env in /etc/profile or /etc/profile.d/hxt-hadoop-env.sh
echo "#hxt-hadoop-env: jave, maven, ant, findbugs, lib, path..." > /etc/profile.d/hxt-hadoop-env.sh
echo "export JAVA_HOME=/usr/lib/jvm/$1" >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$CLASSPATH' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export MAVEN_HOME=/usr/local/apache-maven-3.3.9' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export PATH=$MAVEN_HOME/bin:$PATH' >> /etc/profile.d/hxt-hadoop-env.sh
## MAVEN_OPTS too small size will lead to Apache Hadoop Amazon Web Services or other packages FAILURE and throw OutOfMemoryError exception
#echo 'export MAVEN_OPTS="-Xms256m -Xmx1536m"' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export MAVEN_OPTS="-Xmx4096m -XX:MaxPermSize=768m -XX:+HeapDumpOnOutOfMemoryError"' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export ANT_HOME=/opt/apache-ant-1.9.4' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export PATH=$ANT_HOME/bin:$PATH' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export FINDBUGS_HOME=/opt/findbugs-3.0.1' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export PATH=$FINDBUGS_HOME/bin:$PATH' >> /etc/profile.d/hxt-hadoop-env.sh
echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> /etc/profile.d/hxt-hadoop-env.sh
#jyt echo 'export PATH=/usr/local/bin:$PATH' >> /etc/profile.d/hxt-hadoop-env.sh
source /etc/profile.d/hxt-hadoop-env.sh
echo "===================================================================================================="
echo "********** hxt hadoop env and tools version **********"
export
## check version
## openjdk version "1.8.0_171"
$JAVA_HOME/bin/java -version
## libprotoc 2.5.0
protoc --version
## Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-11T00:41:47+08:00)
mvn -version
echo "===================================================================================================="
}
hadoop_env $DEF_JAVA


#################################################################################################
## build_hadoop
#################################################################################################
build_hadoop(){
echo "===================================================================================================="
echo "********** build_hadoop $1 log **********"
## get hadoop sources... http://hadoop.apache.org/releases.html
if [ ! -e "hadoop-$1-src.tar.gz" ] ; then
  echo "download hadoop source..."
  case $1 in
    2.6.5)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5-src.tar.gz
      ;;
    2.7.6)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.7.6/hadoop-2.7.6-src.tar.gz
      ;;
    2.8.3)
      wget http://archive.apache.org/dist/hadoop/common/hadoop-2.8.3/hadoop-2.8.3-src.tar.gz
      ;;
    2.8.4)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.8.4/hadoop-2.8.4-src.tar.gz
      ;;
    2.9.0)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.0/hadoop-2.9.0-src.tar.gz
      ;;
    2.9.1)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.9.1/hadoop-2.9.1-src.tar.gz
      ;;
    3.0.2)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-3.0.2/hadoop-3.0.2-src.tar.gz
      ;;
    3.1.0)
      wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-3.1.0/hadoop-3.1.0-src.tar.gz
      ;;
  esac
  echo "download hadoop source...ok"
fi

if [ ! -e "hadoop-$1-src" ] ; then
  tar -zxf hadoop-$1-src.tar.gz
fi


## compile hadoop...
cd hadoop-$1-src

## 2.6.5 need java-1.7.0
if [ $1 == "2.6.5" ] ; then
  hadoop_env "java-1.7.0"
fi

#if [ $1 == "2.7.6" -o $1 == "2.8.3" -o $1 == "2.8.4" ] ; then
#  sed -i "s/enforced.maven.version>\[3.0.2/enforced.maven.version>\[3.3.9/g" hadoop-project/pom.xml
#fi
#if [ $1 == "2.9.0" -o $1 == "2.9.1" -o $1 == "3.0.2" -o $1 == "3.1.0" ] ; then
#  sed -i "s/enforced.maven.version>\[3.3.0/enforced.maven.version>\[3.3.9/g" hadoop-project/pom.xml
#fi

## result_build=`mvn clean package -Pdist,native,src -DskipTests -Dtar -Drequire.snappy -Drequire.openssl`
## echo $result_build
mvn clean package -Pdist,native,src -DskipTests -Dtar -Drequire.snappy -Drequire.openssl
if [ $? -ne 0 ]; then
  echo "********** mvn ... failed **********"
  exit -1;
else
  echo "********** mvn ... succeed **********"
fi
echo "===================================================================================================="
cp -rf hadoop-dist/target/hadoop-$1 /usr/local

## 2.8.x 2.9.x have classpath related issue while runtime, it just a workaround
if [ $1 == "2.8.3" -o $1 == "2.8.4" -o $1 == "2.9.0" -o $1 == "2.9.1" ] ; then
  find  hadoop-assemblies/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-build-tools/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-client/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-maven-plugins/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-minicluster/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-project-dist/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-common-project/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/common/ -rf \;
  find  hadoop-hdfs-project/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/hdfs/ -rf \;
  find  hadoop-mapreduce-project/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/mapreduce/ -rf \;
  find  hadoop-tools/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/tools/ -rf \;
  find  hadoop-yarn-project/  -name *.jar -exec cp {} /usr/local/hadoop-$1/share/hadoop/yarn/ -rf \;
fi

## 2.6.5 need java-1.7.0 , resume the default JAVA env
if [ $1 == "2.6.5" ] ; then
  hadoop_env $DEF_JAVA
fi


## prepare test case env
echo "********** prepare test case env **********"
cd /usr/local/hadoop-$1

## JAVA_HOME ...
if [ $1 == "2.6.5" -o $1 == "2.7.6" -o $1 == "2.8.3" -o $1 == "2.8.4" -o $1 == "2.9.0" -o $1 == "2.9.1" ] ; then
  sed -i "s/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/lib\/jvm\/$DEF_JAVA/g" etc/hadoop/hadoop-env.sh
fi
if [ $1 == "3.0.2" -o $1 == "3.1.0" ] ; then
  sed -i "s/# export JAVA_HOME=/export JAVA_HOME=\/usr\/lib\/jvm\/$DEF_JAVA/g" etc/hadoop/hadoop-env.sh
fi

## core-site.xml and hdfs-site.xml for sample test case...
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > etc/hadoop/core-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> etc/hadoop/core-site.xml
echo "<configuration>" >> etc/hadoop/core-site.xml
echo "    <property>" >> etc/hadoop/core-site.xml
echo "        <name>hadoop.tmp.dir</name>" >> etc/hadoop/core-site.xml
echo "        <value>file:$TESTFOLDWEPRE-$1/tmp</value>" >> etc/hadoop/core-site.xml
echo "    </property>" >> etc/hadoop/core-site.xml
echo "    <property>" >> etc/hadoop/core-site.xml
echo "        <name>fs.defaultFS</name>" >> etc/hadoop/core-site.xml
echo "        <value>hdfs://localhost:9000</value>" >> etc/hadoop/core-site.xml
echo "    </property>" >> etc/hadoop/core-site.xml
echo "</configuration>" >> etc/hadoop/core-site.xml

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > etc/hadoop/hdfs-site.xml
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" >> etc/hadoop/hdfs-site.xml
echo "<configuration>" >> etc/hadoop/hdfs-site.xml
echo "    <property>" >> etc/hadoop/hdfs-site.xml
echo "        <name>dfs.replication</name>" >> etc/hadoop/hdfs-site.xml
echo "        <value>1</value>" >> etc/hadoop/hdfs-site.xml
echo "    </property>" >> etc/hadoop/hdfs-site.xml
echo "    <property>" >> etc/hadoop/hdfs-site.xml
echo "        <name>dfs.namenode.name.dir</name>" >> etc/hadoop/hdfs-site.xml
echo "        <value>file:$TESTFOLDWEPRE-$1/tmp/dfs/name</value>" >> etc/hadoop/hdfs-site.xml
echo "    </property>" >> etc/hadoop/hdfs-site.xml
echo "    <property>" >> etc/hadoop/hdfs-site.xml
echo "        <name>dfs.datanode.data.dir</name>" >> etc/hadoop/hdfs-site.xml
echo "        <value>file:$TESTFOLDWEPRE-$1/tmp/dfs/data</value>" >> etc/hadoop/hdfs-site.xml
echo "    </property>" >> etc/hadoop/hdfs-site.xml
echo "</configuration>" >> etc/hadoop/hdfs-site.xml

if [ -e "$TESTFOLDWEPRE-$1" ] ; then
  rm -rf $TESTFOLDWEPRE-$1
fi

if [ $1 == "3.0.2" -o $1 == "3.1.0" ] ; then
  export HDFS_NAMENODE_USER=$USER
  export HDFS_DATANODE_USER=$USER
  export HDFS_SECONDARYNAMENODE_USER=$USER
fi

## sample test case...
echo "hxt-hadoop start namenode..."
bin/hdfs namenode -format
echo "hxt-hadoop start dfs..."
sbin/start-dfs.sh
echo "hxt-hadoop stop dfs..."
sbin/stop-dfs.sh
echo "hxt-hadoop success."
tree $TESTFOLDWEPRE-$1
cd $CURRENTPATH
}

## if first compile 2.6.5 version in a OS, maybe lead Apache Hadoop Amazon Web Services or other packages OutOfMemoryError exception
build_hadoop 2.6.5
build_hadoop 2.7.6
build_hadoop 2.8.3
build_hadoop 2.8.4
build_hadoop 2.9.0
build_hadoop 2.9.1
build_hadoop 3.0.2
build_hadoop 3.1.0

