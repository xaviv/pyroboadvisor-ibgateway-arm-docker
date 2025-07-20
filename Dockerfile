FROM arm64v8/ubuntu:22.04

ENV JDK_VERSION="bellsoft-jdk17.0.16+12-linux-aarch64-full.tar.gz"
ENV JDK_URL="https://download.bell-sw.com/java/17.0.16+12/${JDK_VERSION}"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip xvfb libxtst6 libxrender1 libxi6 libxext6 libxss1 libasound2 \
    fluxbox novnc x11vnc websockify libxrandr2 curl libgtk2.0.0 gettext-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSOL "$JDK_URL" && \
    mkdir -p /opt/java && \
    tar -xzf "$JDK_VERSION" --strip-components=1 -C /opt/java && \
    rm -f "$JDK_VERSION"

ENV JAVA_HOME=/opt/java
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV DISPLAY=:0
ENV VNC_PORT=5900
ENV NOVNC_PORT=6800
ENV SCREEN_WIDTH=800
ENV SCREEN_HEIGHT=600
ENV SCREEN_DEPTH=16

WORKDIR /opt

RUN curl -sSOL "https://github.com/xaviv/pyroboadvisor-ibgateway-arm-docker/releases/download/v1039/ibgateway.tgz" && \
    tar -zxf ibgateway.tgz -C /opt && \
    rm ibgateway.tgz

RUN useradd -m -s /bin/bash ibgateway
RUN chown -R ibgateway:ibgateway /opt/Jts

RUN curl -sSOL "https://github.com/IbcAlpha/IBC/releases/download/3.23.0/IBCLinux-3.23.0.zip" && \
    mkdir -p /opt/ibc && \
    unzip IBCLinux-3.23.0.zip -d /opt && \
    rm IBCLinux-3.23.0.zip
    
COPY private/config.ini /opt/config.ini
# Pendiente actualizar gatewaystart.sh
COPY private/gatewaystart.sh /opt/gatewaystart.sh
COPY arranca.sh /home/ibgateway/arranca.sh
RUN chown -R ibgateway:ibgateway /home/ibgateway/arranca.sh
RUN chmod a+x *.sh scripts/*.sh

EXPOSE 4001 4002 6800 5900

CMD ["/home/ibgateway/arranca.sh", "start"]
