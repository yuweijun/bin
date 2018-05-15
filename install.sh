#!/bin/bash

set -e
set -x

cd $(dirname "$0") || exit
dir="$(pwd)"
dest=$HOME/bin

if [ $USER == "root" ]; then
    dest=/usr/local/bin
fi

if [ ! -e .git/modules ]; then
    git submodule update --init --recursive
elif [ $# -gt 0 ] && [ "$1" = "init" ]; then
    git submodule update --init --recursive
elif [ $# -gt 0 ] && [ "$1" = "remote" ]; then
    git submodule update --init --recursive --remote
else
    echo "usage: ./install.sh [--init|--remote]"
fi

mkdir -p ${dest}/java

if grep -q "${dest}" ~/.bashrc; then
    echo -e "export PATH=${dest}:\$PATH" >> ~/.bashrc
fi

for f in $(ls ${dir}/bash-files)
do
    file=${dir}/bash-files/${f}
    cp "${file}" "${dest}"
done

if [ ! -f ${dest}/greys ]; then
    cp greys-anatomy/bin/greys.sh ${dest}/java
    echo -e "#!/bin/bash\nJAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/java-8-oracle} ${dest}/java/greys.sh \$@" > ${dest}/greys
    chmod a+x ${dest}/greys
fi

if [ ! -f ${dest}/decompiler ] && type ant 2>/dev/null; then
    cd fernflower-decompiler || exit
    ant clean
    ant
    cp fernflower.jar ${dest}/java
    echo -e "#!/bin/bash\njava -jar ${dest}/java/fernflower.jar \$@" > ${dest}/decompiler
    chmod a+x ${dest}/decompiler
    cd -
elif [ -f ${dest}/decompiler ]; then
    echo "decompiler file exists."
elif type ant 2>/dev/null; then
    echo "ant command not found."
fi

if [ ! -f ${dest}/jd-cli ] && type mvn 2>/dev/null; then
    cd jd-cmd || exit
    mvn clean package
    cp jd-cli/target/jd-cli.jar ${dest}/java
    echo -e "#!/bin/bash\njava -jar ${dest}/java/jd-cli.jar \$@" > ${dest}/jd-cli
    chmod a+x ${dest}/jd-cli
    cd -
elif [ -f ${dest}/jd-cli ]; then
    echo "jd-cli file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ${dest}/sslpoke ] && type mvn 2>/dev/null; then
    mvn clean package
    cp target/bin.jar ${dest}/java
    echo -e "#!/bin/bash\njava -cp ${dest}/java/bin.jar SSLPoke \$@" > ${dest}/sslpoke
    chmod a+x ${dest}/sslpoke
elif [ -f ${dest}/sslpoke ]; then
    echo "sslpoke file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ${dest}/sjk ] && type mvn 2>/dev/null; then
    cd jvm-tools || exit
    mvn clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ${dest}/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar ${dest}/java/sjk.jar \$@" > ${dest}/sjk
    chmod a+x ${dest}/sjk
    cd -
elif [ -f ${dest}/sjk ]; then
    echo "sjk file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

