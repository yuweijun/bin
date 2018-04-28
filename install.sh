#!/bin/bash

git submodule update --init --remote --recursive

directory=$(dirname "$0")
cd ${directory}
dir="$(pwd)"

if [ ! -f ~/bin/decompiler ] && type ant 2>/dev/null; then
    cd fernflower-decompiler
    ant clean
    ant
    mkdir -p ~/bin/java
    cp fernflower.jar ~/bin/java
    echo "#!/bin/bash\njava -jar ~/bin/java/fernflower.jar $@" > ~/bin/decompiler
    chmod a+x ~/bin/decompiler
    cd ..
fi

if [ ! -f ~/bin/greys ]; then
    mkdir -p ~/bin/java
    cp greys-anatomy/bin/greys.sh ~/bin/java
    echo "#!/bin/bash\nJAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-8-oracle} ~/bin/java/greys.sh $@" > ~/bin/greys
    chmod a+x ~/bin/greys
fi