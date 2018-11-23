#!/bin/bash

# set -e
# set -x

cd $(dirname "$0") || exit
DIR="$(pwd)"
DEST=${DIR}/bash-files

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

if [ 'greys' ]; then
    cp greys-anatomy/bin/greys.sh ${DEST}/java
    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME} \${HOME}/bin/java/greys.sh \$@" > ${DEST}/greys
    chmod a+x ${DEST}/greys
fi

if ! type ant 2>/dev/null; then
    echo "ant command not found"
else
    if [ 'decompiler' ]; then
        cd fernflower-decompiler || exit
        ant clean
        ant
        cp fernflower.jar ${DEST}/java
        echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/fernflower.jar \$@" > ${DEST}/decompiler
        chmod a+x ${DEST}/decompiler
        cd -
    fi
fi

if ! type mvn 2>/dev/null; then
    echo "mvn command not found"
    exit 0
fi

if [ 'jd-cli' ]; then
    cd jd-cmd || exit
    mvn -Dmaven.test.skip=true clean package
    cp jd-cli/target/jd-cli.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/jd-cli.jar \$@" > ${DEST}/jd-cli
    chmod a+x ${DEST}/jd-cli
    cd -
fi

if [ 'sjk' ]; then
    cd jvm-tools || exit
    mvn -Dmaven.test.skip=true clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ${DEST}/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/sjk.jar \$@" > ${DEST}/sjk
    chmod a+x ${DEST}/sjk
    cd -
fi

if [ 'btrace' ]; then
    cd btrace
    git checkout -b v1.3.11.1
    ./gradlew build -x test -x javadoc

    cp bin/btrace ${DEST}/java/btrace
    cp build/btrace-*.jar ${DEST}/java/build
    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME}\nexport BTRACE_HOME=\${HOME}/bin/java\n\${HOME}/bin/java/btrace \$@" > ${DEST}/btrace
    chmod a+x ${DEST}/btrace
    cd -
fi

if [ 'bin' ]; then
    mvn clean package
    cp target/bin.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -cp \${HOME}/bin/java/bin.jar SSLPoke \$@" > ${DEST}/sslpoke
    chmod a+x ${DEST}/sslpoke
fi

for f in $(ls ${DEST})
do
    file=${DEST}/${f}
    mkdir -p ${HOME}/bin
    cp -r "${file}" ${HOME}/bin
done

