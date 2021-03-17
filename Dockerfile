FROM ubuntu:20.04

ENV TZ=UTC
ENV PATH="/home/dockeruser/.cargo/bin:$PATH"

WORKDIR /lichess

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt update && \
    
    apt install -y curl wget gnupg && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && bash nodesource_setup.sh && \
    
    apt update && \
    apt install -y git build-essential unzip parallel default-jre sbt nodejs python2 mongodb-org redis-server && \
    npm install --global yarn && \
    
    git clone --recursive https://github.com/ornicar/lila.git /lichess/lila && \
    git clone https://github.com/ornicar/lila-ws.git /lichess/lila-ws && \
    git clone https://github.com/ornicar/lila-fishnet.git /lichess/lila-fishnet && \
    git clone --recursive https://github.com/niklasf/fishnet.git /lichess/fishnet && \
    
    groupadd -g 1000 -o dockeruser && \
    useradd -m -u 1000 -g 1000 -d /home/dockeruser -o -s /bin/bash dockeruser && \
    chown -R 1000:1000 /home/dockeruser && \

    mkdir -p /data/db && \
    chown -R 1000:1000 /data/db && \
    chown -R 1000:1000 /lichess

USER dockeruser

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    cd /lichess/lila && ./ui/build && \
    cd /lichess/lila && ./lila clean compile && \
    cd /lichess/fishnet && cargo build && \
    cd /lichess/lila-ws && sbt clean compile

COPY ./run-lichess-dev.sh /lichess/run-lichess-dev.sh

EXPOSE 9663
EXPOSE 9664

CMD ["/bin/bash", "./run-lichess-dev.sh"]
