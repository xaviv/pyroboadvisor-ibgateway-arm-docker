FROM arm64v8/ubuntu:22.04

# Parameters
ENV JAVA_HOME=/opt/java
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV DISPLAY=:0
ENV VNC_PORT=5900
ENV NOVNC_PORT=6800
ENV SCREEN_WIDTH=800
ENV SCREEN_HEIGHT=600
ENV SCREEN_DEPTH=16
ENV JDK_VERSION="bellsoft-jdk17.0.16+12-linux-aarch64-full.tar.gz"
ENV JDK_URL="https://download.bell-sw.com/java/17.0.16+12/${JDK_VERSION}"
ENV PYROBOADVISOR_URL="https://github.com/daradija/pyroboadvisor/archive/refs/heads/main.zip"
ENV IB_GATEWAY_URL="https://github.com/xaviv/pyroboadvisor-ibgateway-arm-docker/releases/download/v1039/ibgateway.tgz"
ENV IBC_URL="https://github.com/IbcAlpha/IBC/releases/download/3.23.0/IBCLinux-3.23.0.zip"

# Set up system
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip xvfb libxtst6 libxrender1 libxi6 libxext6 libxss1 libasound2 \
    fluxbox novnc x11vnc websockify libxrandr2 curl libgtk2.0.0 gettext-base pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#Set up JDK
RUN curl -sSOL "$JDK_URL" && \
    mkdir -p /opt/java && \
    tar -xzf "$JDK_VERSION" --strip-components=1 -C /opt/java && \
    rm -f "$JDK_VERSION"


WORKDIR /opt

# Set up IB Gateway
RUN curl -sSOL "$IB_GATEWAY_URL" && \
    tar -zxf ibgateway.tgz -C /opt && \
    rm ibgateway.tgz

RUN useradd -m -s /bin/bash pyroboadvisor
RUN chown -R pyroboadvisor:pyroboadvisor /opt/Jts

# Set up IBC
RUN curl -sSOL "$IBC_URL" && \
    mkdir -p /opt/ibc && \
    unzip IBCLinux-3.23.0.zip -d /opt && \
    rm IBCLinux-3.23.0.zip

# Set up Pyroboadvisor
RUN curl -sSOL "$PYROBOADVISOR_URL" && \
    unzip main.zip && \
    rm main.zip && \
    mv pyroboadvisor-main /home/pyroboadvisor && \
    chown -R pyroboadvisor:pyroboadvisor /home/pyroboadvisor && \
    pip install --no-cache-dir -r /home/pyroboadvisor/pyroboadvisor-main/requirements.txt && \
    pip install --no-cache-dir -r /home/pyroboadvisor/pyroboadvisor-main/driver/requirements.txt

# Pendiente: Puerto live 4001. Configurar sample

# Set up launcher
COPY private/config.ini /opt/config.ini
# Pendiente actualizar gatewaystart.sh
COPY private/gatewaystart.sh /opt/gatewaystart.sh
COPY arranca.sh /home/pyroboadvisor/arranca.sh
RUN chown -R pyroboadvisor:pyroboadvisor /home/pyroboadvisor/arranca.sh
RUN chmod a+x *.sh scripts/*.sh

EXPOSE 6800

CMD ["/home/pyroboadvisor/arranca.sh", "start"]
