FROM ling/jdk7:7u80

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
