#!/bin/bash

cd $(dirname "$0")
dir="$(pwd)"

mkdir -p ~/bin/java

if grep -q "HOME/bin" ~/.bashrc; then
    echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
fi

for f in $(ls ${dir}/bash-files)
do
    file=${dir}/bash-files/${f}
    if [ ! -f ~/bin/${f} ]; then
        echo "cp ${file} ~/bin"
        cp ${file} ~/bin
    else
        echo "~/bin/${f} is exists"
    fi
done

# exit 0

echo "git submodule update --init --remote --recursive"
git submodule update --init --remote --recursive

if [ ! -f ~/bin/greys ]; then
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
    mvn clean package
    cp target/bin.jar ~/bin/java
    echo -e "#!/bin/bash\njava -cp ~/bin/java/bin.jar SSLPoke \$@" > ~/bin/sslpoke
    chmod a+x ~/bin/sslpoke
elif [ -f ~/bin/sslpoke ]; then
    echo "sslpoke file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if [ ! -f ~/bin/sjk ] && type mvn 2>/dev/null; then
    mkdir -p ~/bin/java
    cd jvm-tools
    mvn clean package
    cp sjk/target/sjk-*-SNAPSHOT.jar ~/bin/java/sjk.jar
    echo -e "#!/bin/bash\njava -jar ~/bin/java/sjk.jar \$@" > ~/bin/sjk
    chmod a+x ~/bin/sjk
elif [ -f ~/bin/sjk ]; then
    echo "sjk file exists."
elif type mvn 2>/dev/null; then
    echo "mvn command not found."
fi

if grep -q NVM_DIR ~/.bashrc 2>/dev/null; then
    echo "NVM_DIR config found"
else
    echo "export NVM_DIR=\"${dir}/nvm\"" >> ~/.bashrc
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> ~/.bashrc
    echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"" >> ~/.bashrc
fi

if [ -f ~/bin/mitmproxy ]; then
    echo "~/bin/mitmproxy found"
else
    cd ${dir}/mitmproxy
    ./dev.sh
    cp ${dir}/mitmproxy/venv/bin/mitm* ~/bin
    cd -
fi

