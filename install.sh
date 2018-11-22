#!/bin/bash

cd $(dirname "$0") || exit
DIR="$(pwd)"

FORCE=false
DEST=${DIR}/bash-files

while getopts f arg; do
    case "$arg" in
        f) FORCE=true ;;
        ?) printf "Usage: %s: [-f]\n" $0
            exit 2;;
    esac
done

# set -e
# set -x

git submodule update --init --recursive

if [ -e /usr/libexec/java_home ]; then
    JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
else
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
fi

mkdir -p ${DEST}/java/build

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

mvn clean package
cp target/bin.jar ${DEST}/java
echo -e "#!/bin/bash\njava -cp \${HOME}/bin/java/bin.jar SSLPoke \$@" > ${DEST}/sslpoke
chmod a+x ${DEST}/sslpoke

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

if [ ! -f ${DEST}/sjk ] || ${FORCE}; then
    cd jvm-tools || exit
    mvn -Dmaven.test.skip=true clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ${DEST}/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/sjk.jar \$@" > ${DEST}/sjk
    chmod a+x ${DEST}/sjk
    cd -
elif [ -f ${DEST}/sjk ]; then
    echo "sjk file exists."
fi

if [ ! -f ${DEST}/btrace ] || ${FORCE}; then
    cd btrace
    git checkout -b v1.3.11.1
    ./gradlew build -x test -x javadoc

    cp bin/btrace ${DEST}/java/btrace
    cp build/btrace-*.jar ${DEST}/java/build
    echo -e "#!/bin/bash\nJAVA_HOME=${JAVA_HOME}\nBTRACE_HOME=\${HOME}/bin/java\n\${HOME}/bin/java/btrace \$@" > ${DEST}/btrace
    chmod a+x ${DEST}/btrace
    cd -
elif [ -f ${DEST}/btrace ]; then
    echo "btrace file exists."
fi

for f in $(ls ${DEST})
do
    file=${DEST}/${f}
    mkdir -p ${HOME}/bin
    cp -r "${file}" ${HOME}/bin
done

