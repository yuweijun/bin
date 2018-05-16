#!/bin/bash

ARGV=$(getopt -o ir -l init,remote -- "$@")
if [ $? != 0 ] ; then
    echo "getopt error"
fi

eval set -- "$ARGV"

INIT=false
REMOTE=false

while true; do
  case "$1" in
    -i | --init ) INIT=true; shift ;;
    -r | --remote ) REMOTE=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

set -e
# set -x

cd $(dirname "$0") || exit

DIR="$(pwd)"
DEST=$HOME/bin

if [ $UID -eq 0 ]; then
    DEST=/usr/local/bin
fi

if $INIT; then
    git submodule update --init --recursive
elif $REMOTE; then
    git submodule update --init --recursive --remote
else
    if [ ! -e .git/modules ]; then
        git submodule update --init --recursive
    fi
    echo "usage: ./install.sh [--init|--remote]"
fi

mkdir -p ${DEST}/java

if grep -q "${DEST}" $HOME/.bashrc; then
    echo -e "export PATH=${DEST}:\$PATH" >> $HOME/.bashrc
fi

for f in $(ls ${DIR}/bash-files)
do
    file=${DIR}/bash-files/${f}
    cp "${file}" "${DEST}"
done

if [ ! -f ${DEST}/greys ]; then
    cp greys-anatomy/bin/greys.sh ${DEST}/java
    echo -e "#!/bin/bash\nJAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/java-8-oracle} ${DEST}/java/greys.sh \$@" > ${DEST}/greys
    chmod a+x ${DEST}/greys
fi

if [ ! -f ${DEST}/decompiler ] && type ant 2>/dev/null; then
    cd fernflower-decompiler || exit
    ant clean
    ant
    cp fernflower.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -jar ${DEST}/java/fernflower.jar \$@" > ${DEST}/decompiler
    chmod a+x ${DEST}/decompiler
    cd -
elif [ -f ${DEST}/decompiler ]; then
    echo "decompiler file exists."
elif type ant 2>/dev/null; then
    echo "ant command not found."
fi

if [ ! -f ${DEST}/jd-cli ] && type mvn 2>/dev/null; then
    cd jd-cmd || exit
    mvn clean package
    cp jd-cli/target/jd-cli.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -jar ${DEST}/java/jd-cli.jar \$@" > ${DEST}/jd-cli
    chmod a+x ${DEST}/jd-cli
    cd -
elif [ -f ${DEST}/jd-cli ]; then
    echo "jd-cli file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ${DEST}/sslpoke ] && type mvn 2>/dev/null; then
    mvn clean package
    cp target/bin.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -cp ${DEST}/java/bin.jar SSLPoke \$@" > ${DEST}/sslpoke
    chmod a+x ${DEST}/sslpoke
elif [ -f ${DEST}/sslpoke ]; then
    echo "sslpoke file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ${DEST}/sjk ] && type mvn 2>/dev/null; then
    cd jvm-tools || exit
    mvn clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ${DEST}/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar ${DEST}/java/sjk.jar \$@" > ${DEST}/sjk
    chmod a+x ${DEST}/sjk
    cd -
elif [ -f ${DEST}/sjk ]; then
    echo "sjk file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

