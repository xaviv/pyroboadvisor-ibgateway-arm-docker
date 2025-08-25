FROM arm64v8/ubuntu:22.04

# Parameters
ENV IbLoginId=
ENV IbPassword=
ENV TradingMode=live
ENV AcceptNonBrokerageAccountWarning=yes
ENV ReadOnlyApi=no
ENV BypassOrderPrecautions=yes
ENV fecha_inicio=2019-01-01
ENV money=100000
ENV numberStocksInPortfolio=10
ENV orderMarginBuy=0.005
ENV orderMarginSell=0.005
ENV apalancamiento=1.7
ENV ring_size=252
ENV rlog_size=22
ENV cabeza=5
ENV seeds=100
ENV percentil=95
ENV prediccion=1
ENV key=
ENV email=
ENV modo=3
ENV hora=10:00
ENV puerto=4001
ENV enable_novnc=1

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
ENV PYROBOADVISOR_URL="https://github.com/daradija/pyroboadvisor/archive/refs/heads/selfhosting.zip"
ENV PYROBOADVISOR_SHA256="b6cf0ebf402d4e1913bb469da3f93d7a9a0ce93dcc4446480c60de30e9371a79cd "
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
    echo "$PYROBOADVISOR_SHA256 selfhosting.zip" | sha256sum -c - && \
    unzip selfhosting.zip && \
    rm selfhosting.zip && \
    mv pyroboadvisor-selfhosting /home/pyroboadvisor && \
    mkdir /home/pyroboadvisor/pyroboadvisor-selfhosting/private && \
    chown -R pyroboadvisor:pyroboadvisor /home/pyroboadvisor && \
    pip install --no-cache-dir -r /home/pyroboadvisor/pyroboadvisor-selfhosting/requirements.txt && \
    pip install --no-cache-dir -r /home/pyroboadvisor/pyroboadvisor-selfhosting/driver/requirements.txt 

#COPY private/pyroboadvisor.config /home/pyroboadvisor/pyroboadvisor-selfhosting/private/pyroboadvisor.config
RUN chown -R pyroboadvisor:pyroboadvisor /home/pyroboadvisor/pyroboadvisor-selfhosting/private

# Set up launcher
#COPY private/config.ini /opt/config.ini

COPY gatewaystart.sh /opt/gatewaystart.sh
COPY arranca.sh /home/pyroboadvisor/arranca.sh
RUN chown -R pyroboadvisor:pyroboadvisor /home/pyroboadvisor/arranca.sh
RUN chmod a+x *.sh scripts/*.sh

EXPOSE 6800

CMD ["/home/pyroboadvisor/arranca.sh", "start"]
