#!/bin/bash

echo "git submodule update --init --remote --recursive"
git submodule update --init --remote --recursive

directory=$(dirname "$0")
cd ${directory}
dir="$(pwd)"

if grep -q "HOME/bin" ~/.bashrc; then
    echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
fi

if [ ! -f ~/bin/greys ]; then
    mkdir -p ~/bin/java
    cp greys-anatomy/bin/greys.sh ~/bin/java
    echo -e "#!/bin/bash\nJAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/java-8-oracle} ~/bin/java/greys.sh \$@" > ~/bin/greys
    chmod a+x ~/bin/greys
fi

if [ ! -f ~/bin/decompiler ] && type ant 2>/dev/null; then
    cd fernflower-decompiler
    ant clean
    ant
    mkdir -p ~/bin/java
    cp fernflower.jar ~/bin/java
    echo -e "#!/bin/bash\njava -jar ~/bin/java/fernflower.jar \$@" > ~/bin/decompiler
    chmod a+x ~/bin/decompiler
    cd ..
elif [ -f ~/bin/decompiler ]; then
    echo "decompiler file exists."
elif type ant 2>/dev/null; then
    echo "ant command not found."
fi

if [ ! -f ~/bin/jd-cli ] && type mvn 2>/dev/null; then
    mkdir -p ~/bin/java
    cd jd-cmd
    mvn clean package
    cp jd-cli/target/jd-cli.jar ~/bin/java
    echo -e "#!/bin/bash\njava -jar ~/bin/java/jd-cli.jar \$@" > ~/bin/jd-cli
    chmod a+x ~/bin/jd-cli
elif [ -f ~/bin/jd-cli ]; then
    echo "jd-cli file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ~/bin/sslpoke ] && type mvn 2>/dev/null; then
    mkdir -p ~/bin/java
    mvn clean package
    cp target/bin.jar ~/bin/java
    echo -e "#!/bin/bash\njava -cp ~/bin/java/bin.jar SSLPoke \$@" > ~/bin/sslpoke
    chmod a+x ~/bin/sslpoke
elif [ -f ~/bin/sslpoke ]; then
    echo "sslpoke file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi
