#!/bin/bash

ARGV=$(getopt -o rif -l remote,init,force -- "$@")
if [ $? != 0 ] ; then
    echo "getopt error"
fi

eval set -- "$ARGV"

cd $(dirname "$0") || exit

DIR="$(pwd)"

INIT=false
REMOTE=false
FORCE=false
DEST=${DIR}/bash-files

while true; do
  case "$1" in
    -r | --remote ) REMOTE=true; shift ;;
    -i | --init ) INIT=true; shift ;;
    -f | --force ) FORCE=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# set -e
# set -x

if $INIT; then
    git submodule update --init --recursive
elif $REMOTE; then
    git submodule update --init --recursive --remote
else
    if [ ! -e .git/modules ]; then
        git submodule update --init --recursive
    fi
    echo "usage: ./install.sh [--init|--remote|--force]"
fi

mkdir -p ${DEST}/java

if grep -q "${DEST}" $HOME/.bashrc; then
    echo -e "export PATH=${DEST}:\$PATH" >> $HOME/.bashrc
fi

if [ ! -f ${DEST}/greys ] || ${FORCE}; then
    cp greys-anatomy/bin/greys.sh ${DEST}/java
    echo -e "#!/bin/bash\nJAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/java-8-oracle} \${HOME}/bin/java/greys.sh \$@" > ${DEST}/greys
    chmod a+x ${DEST}/greys
fi

if ! type ant 2>/dev/null; then
    echo "ant command not found"
else
    if [ ! -f ${DEST}/decompiler ] || $FORCE; then
        cd fernflower-decompiler || exit
        ant clean
        ant
        cp fernflower.jar ${DEST}/java
        echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/fernflower.jar \$@" > ${DEST}/decompiler
        chmod a+x ${DEST}/decompiler
        cd -
    elif [ -f ${DEST}/decompiler ]; then
        echo "decompiler file exists."
    fi
fi

if ! type mvn 2>/dev/null; then
    echo "mvn command not found"
    exit 0
fi

if [ ! -f ${DEST}/jd-cli ] || ${FORCE}; then
    cd jd-cmd || exit
    mvn clean package
    cp jd-cli/target/jd-cli.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/jd-cli.jar \$@" > ${DEST}/jd-cli
    chmod a+x ${DEST}/jd-cli
    cd -
elif [ -f ${DEST}/jd-cli ]; then
    echo "jd-cli file exists."
fi

if [ ! -f ${DEST}/sslpoke ] || ${FORCE}; then
    mvn clean package
    cp target/bin.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -cp \${HOME}/bin/java/bin.jar SSLPoke \$@" > ${DEST}/sslpoke
    chmod a+x ${DEST}/sslpoke
elif [ -f ${DEST}/sslpoke ]; then
    echo "sslpoke file exists."
fi

if [ ! -f ${DEST}/sjk ] || ${FORCE}; then
    cd jvm-tools || exit
    mvn clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ${DEST}/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/sjk.jar \$@" > ${DEST}/sjk
    chmod a+x ${DEST}/sjk
    cd -
elif [ -f ${DEST}/sjk ]; then
    echo "sjk file exists."
fi

for f in $(ls ${DEST})
do
    file=${DEST}/${f}
    mkdir -p ${HOME}/bin
    cp -r "${file}" ${HOME}/bin
done

