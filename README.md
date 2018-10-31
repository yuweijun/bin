## install softwares in ubuntu

    $ sudo os/ubuntu.sh

### install softwares in centos7 as root

    $ os/centos7.sh

## install with init

    $ git clone https://github.com/yuweijun/bin.git bin.git
    $ cd bin.git
    $ sudo os/ubuntu.sh
    $ ./install.sh init

### reinstall

    $ ./install.sh

## 保存字节码生成的classes

    1. cglib生成的类保存目录为：`target/cblib-classes`
    1. 反射生成的类保存目录为：`target/generated-classes`

## run example

    $ mvn clean package
    $ java -javaagent:target/bin.jar SSLPoke www.baidu.com 443
    $ java -cp target/bin.jar Pinyin 中文
    $ java -jar target/bin.jar 中文
