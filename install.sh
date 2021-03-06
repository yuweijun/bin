#!/bin/bash

# set -e
# set -x

cd $(dirname "$0") || exit
DIR="$(pwd)"
DEST=${DIR}/bash-files

if ! type mvn 2>/dev/null; then
    echo "mvn command not found"
    exit 0
fi

COMPILE=false

if [ $# -gt 0 ]; then
    COMPILE=true
fi

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

if [ 'bin' ]; then
    mvn clean package
    cp target/bin.jar ${DEST}/java
    echo -e "#!/bin/bash\njava -cp \${HOME}/bin/java/bin.jar SSLPoke \$@" > ${DEST}/sslpoke
    chmod a+x ${DEST}/sslpoke
    echo -e "#!/bin/bash\njava -javaagent:\${HOME}/bin/java/bin.jar \$@" > ${DEST}/java-dump-proxy-classes
    chmod a+x ${DEST}/java-dump-proxy-classes
fi

if [ 'arthas' ]; then
    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME}\n\${HOME}/bin/java/as.sh \$@" > ${DEST}/arthas
    chmod a+x ${DEST}/arthas
fi

if [ 'greys' ]; then
    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME}\n\${HOME}/bin/java/greys.sh \$@" > ${DEST}/greys
    chmod a+x ${DEST}/greys
fi

if [ 'javad' ]; then
    if $COMPILE; then
        if type ant 2>/dev/null; then
            cd fernflower-decompiler || exit
            ant clean
            ant
            cp fernflower.jar ${DEST}/java
            cd -
        fi
    fi

    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/fernflower.jar \$@" > ${DEST}/javad
    chmod a+x ${DEST}/javad
fi

if [ 'jd-cli' ]; then
    if $COMPILE; then
        cd jd-cmd || exit
        mvn -Dmaven.test.skip=true clean package
        cp jd-cli/target/jd-cli.jar ${DEST}/java
        cd -
    fi

    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/jd-cli.jar \$@" > ${DEST}/jd-cli
    chmod a+x ${DEST}/jd-cli
fi

if [ 'sjk' ]; then
    if $COMPILE; then
        cd jvm-tools || exit
        mvn -Dmaven.test.skip=true clean package
        cp sjk/target/sjk-*-SNAPSHOT.jar ${DEST}/java/sjk.jar
        cd -
    fi

    echo -e "#!/bin/bash\njava -jar \${HOME}/bin/java/sjk.jar \$@" > ${DEST}/sjk
    chmod a+x ${DEST}/sjk
fi

if [ 'btrace' ]; then
    if $COMPILE; then
        cd btrace
        git checkout v1.3.11.1
        ./gradlew build -x test -x javadoc
        cp bin/btrace ${DEST}/java/btrace
        cp build/btrace-*.jar ${DEST}/java/build
        cd -
    fi

    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME}\nexport BTRACE_HOME=\${HOME}/bin/java\n\${HOME}/bin/java/btrace \$@" > ${DEST}/btrace
    chmod a+x ${DEST}/btrace
fi

if [ 'java print assembly' ]; then
    echo -e "#!/bin/bash\nexport JAVA_HOME=${JAVA_HOME}\njava -server -Xcomp -XX:CompileThreshold=1 -XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints -XX:+TraceClassLoading -XX:+PrintAssembly -XX:+LogCompilation -XX:LogFile=\${HOME}/logs/java.print.assembly-\$(date +\"%Y-%m-%d\").log \$@" > ${DEST}/jassembly
    chmod a+x ${DEST}/jassembly
fi

for f in $(ls ${DEST})
do
    file=${DEST}/${f}
    mkdir -p ${HOME}/bin
    cp -r "${file}" ${HOME}/bin
done

git reset --hard

