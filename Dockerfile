FROM centos:7.4.1708

# Java Version and other ENV
ENV JAVA_VERSION_MAJOR=7 \
    JAVA_VERSION_MINOR=79 \
    JAVA_VERSION_BUILD=15 \
    JAVA_PACKAGE=jdk \
    JAVA=/usr/java/default/bin/java \
    JAVA_HOME=/usr/java/default \
    PATH=${PATH}:/usr/java/default/bin \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_COLLATE="C" \
    LC_CTYPE="en_US.UTF-8"

# install java
RUN mkdir /usr/java && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | gunzip -c - | tar -C /usr/java -xf - && \
    ln -s /usr/java/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /usr/java/default && \
    rm -rf /usr/java/default/*src.zip \
        /usr/java/default/jre/bin/javaws \
        /usr/java/default/jre/bin/jjs \
        /usr/java/default/jre/bin/keytool \
        /usr/java/default/jre/bin/orbd \
        /usr/java/default/jre/bin/pack200 \
        /usr/java/default/jre/bin/policytool \
        /usr/java/default/jre/bin/rmid \
        /usr/java/default/jre/bin/rmiregistry \
        /usr/java/default/jre/bin/servertool \
        /usr/java/default/jre/bin/tnameserv \
        /usr/java/default/jre/bin/unpack200 \
        /usr/java/default/jre/lib/*javafx* \
        /usr/java/default/jre/lib/*jfx* \
        /usr/java/default/jre/lib/amd64/libdecora_sse.so \
        /usr/java/default/jre/lib/amd64/libfxplugins.so \
        /usr/java/default/jre/lib/amd64/libglass.so \
        /usr/java/default/jre/lib/amd64/libgstreamer-lite.so \
        /usr/java/default/jre/lib/amd64/libjavafx*.so \
        /usr/java/default/jre/lib/amd64/libjfx*.so \
        /usr/java/default/jre/lib/amd64/libprism_*.so \
        /usr/java/default/jre/lib/deploy* \
        /usr/java/default/jre/lib/desktop \
        /usr/java/default/jre/lib/ext/jfxrt.jar \
        /usr/java/default/jre/lib/ext/nashorn.jar \
        /usr/java/default/jre/lib/javaws.jar \
        /usr/java/default/jre/lib/jfr* \
        /usr/java/default/jre/lib/oblique-fonts \
        /usr/java/default/jre/lib/plugin.jar \
        /usr/java/default/jre/plugin \
        /usr/java/default/lib/*javafx* \
        /usr/java/default/lib/missioncontrol \
        /usr/java/default/lib/visualvm \
        /tmp/* /var/cache/apk/* && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# Update dependencies
RUN echo "[epel]" > /etc/yum.repos.d/epel.repo && \
    echo "name=Extra Packages for CentOS 7" >> /etc/yum.repos.d/epel.repo && \
    echo "baseurl=http://mirror.es.its.nyu.edu/epel/7/x86_64" >> /etc/yum.repos.d/epel.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/epel.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/epel.repo && \
    yum groupinstall -y 'Development Tools' && \
    yum install -y git ansible make wget tar openssl-devel libkrb5-dev freetype fontconfig && \
    yum clean all && \
    rm -f /etc/yum.repos.d/epel.repo

# Maven
ENV MAVEN_VERSION=3.3.9
RUN mkdir /root/.maven && \
    curl -jksSL http://www.us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    | tar -xzf - --strip-components=1 -C /root/.maven

# Go
ENV GO_VERSION=1.9.1
RUN curl -jksSL https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz \
    | tar -xzf - -C /usr/local

# Nodejs
ENV NODEJS_VERSION=6.11.4
RUN curl -jksSL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz \
    | tar -xzf - --strip-components=1 -C /usr/local

# Yarn
ENV YARN_VERSION=1.2.1
RUN npm install -g yarn@${YARN_VERSION}

# Docker
ENV DOCKER_VERSION=1.12.4
RUN curl -jksSL https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz \
    | tar -xzf - --strip-components=1 -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/docker*

# Docker Compose
ENV DOCKER_COMPOSE_VERSION=1.9.0
RUN curl -Lo /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 && \
    chmod +x /usr/local/bin/docker-compose

# Ansible Config
ADD config/ansible/ansible.cfg /etc/ansible/ansible.cfg

# Environment settings
ENV JAVA_OPTS="-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom -server -XX:+UseParallelGC" \
    GOROOT="/usr/local/go" \
    GOPATH="/root/go" \
    M2_HOME="/root/.maven" \
    DOCKER_HOST=tcp://docker:2375 \
    PATH="/usr/local/go/bin:/root/.maven/bin:$PATH"

WORKDIR /root
