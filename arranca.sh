#!/bin/bash

printf "fecha_inicio=%s\nmoney=%s\nnumberStocksInPortfolio=%s\norderMarginBuy=%s\norderMarginSell=%s\napalancamiento=%s\nring_size=%s\nrlog_size=%s\ncabeza=%s\nseeds=%s\npercentil=%s\nprediccion=%s\nkey=%s\nemail=%s\nmodo=%s\nhora=%s\npuerto=%s" \
    "$fecha_inicio" "$money" "$numberStocksInPortfolio" "$orderMarginBuy" "$orderMarginSell" "$apalancamiento" \
    "$ring_size" "$rlog_size" "$cabeza" "$seeds" "$percentil" "$prediccion" "$key" "$email" "$modo" "$hora" "$puerto" > /home/pyroboadvisor/pyroboadvisor-selfhosting/private/pyroboadvisor.config
printf "IbLoginId=%s\nIbPassword=%s\nTradingMode=%s\nAcceptNonBrokerageAccountWarning=%s\nReadOnlyApi=%s\nBypassOrderPrecautions=%s\n" \
    "$IbLoginId" "$IbPassword" "$TradingMode" "$AcceptNonBrokerageAccountWarning" "$ReadOnlyApi" "$BypassOrderPrecautions" > /opt/config.ini
    
set -e

Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
export DISPLAY=:0
sleep 3

fluxbox &
sleep 2

x11vnc -display :0 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever &
sleep 2

websockify --web=/usr/share/novnc 6800 localhost:5900 &

export JAVA_HOME="/opt/java/bin"
export INSTALL4J_JAVA_HOME="${JAVA_HOME}" 
export app_java_home="${JAVA_HOME}" 

cd /opt
/opt/gatewaystart.sh > /var/log/ibgateway.log 2>&1 &
xterm -hold -e "/usr/bin/python3 /home/pyroboadvisor/pyroboadvisor-selfhosting/sample.py" 
