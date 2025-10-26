#!/bin/bash

# Crear los archivos de configuracion para pyroboadvisor e IB Gateway usando las variables de entorno
printf "fecha_inicio=%s\nmoney=%s\nnumberStocksInPortfolio=%s\norderMarginBuy=%s\norderMarginSell=%s\napalancamiento=%s\nring_size=%s\nrlog_size=%s\ncabeza=%s\nseeds=%s\npercentil=%s\nprediccion=%s\nkey=%s\nemail=%s\nmodo=%s\nhora=%s\npuerto=%s\nsource=%s\nhar=%s\nhretorno=%s\nhrandom=%s\nmultiploMantenimiento=%s\nb=%s\neodhd_key=%s\npoligon_key=%s" \
    "$fecha_inicio" "$money" "$numberStocksInPortfolio" "$orderMarginBuy" "$orderMarginSell" "$apalancamiento" \
    "$ring_size" "$rlog_size" "$cabeza" "$seeds" "$percentil" "$prediccion" "$key" "$email" "$modo" "$hora" "$puerto" \
    "$source" "$har" "$hretorno" "$hrandom" "$multiploMantenimiento" "$b" "$eodhd_key" "$poligon_key" > /home/pyroboadvisor/pyroboadvisor-selfhosting/private/pyroboadvisor.config
printf "IbLoginId=%s\nIbPassword=%s\nTradingMode=%s\nAcceptNonBrokerageAccountWarning=%s\nReadOnlyApi=%s\nReadOnlyLogin=%s\nBypassOrderPrecautions=%s\nReloginAfterSecondFactorAuthenticationTimeout=yes\n" \
    "$IbLoginId" "$IbPassword" "$TradingMode" "$AcceptNonBrokerageAccountWarning" "$ReadOnlyApi" "$ReadOnlyApi" "$BypassOrderPrecautions" > /opt/config.ini

# Salir si falla alguno de los comandos
set -e

# Inicializacion del entorno grafico
if [ -e /tmp/.X0-lock ]; then
    echo "Display :0 ocupado. Eliminando el lock..."
    rm -f /tmp/.X0-lock
fi
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!
export DISPLAY=:0
for i in {1..30}; do
    if xdpyinfo -display :0 > /dev/null 2>&1; then
        echo "Xvfb arrancado correctamente (PID $XVFB_PID)"
        break
    else
        echo "Esperando a Xvfb..."
        sleep 1
    fi
done
if ! xdpyinfo -display :0 > /dev/null 2>&1; then
    echo "Xvfb no ha arrancado correctamente. Parando docker."
    exit 1
fi
fluxbox &
sleep 2
x11vnc -display :0 -nopw -listen localhost -xkb -ncache 10 -ncache_cr -forever -o /var/log/x11vnc.log &
sleep 2

if [ -n "$enable_novnc" ] && [ "$enable_novnc" -eq 1 ]; then
    websockify --web=/usr/share/novnc 6800 localhost:5900 &
fi

# Arrancar IB Gateway
export JAVA_HOME="/opt/java/bin"
export INSTALL4J_JAVA_HOME="${JAVA_HOME}" 
export app_java_home="${JAVA_HOME}" 
mkdir -p /var/run
cd /opt
/opt/gatewaystart.sh &
trap 'echo "Parando IB Gateway..."; kill_ibgateway; exit 1' SIGINT SIGTERM >> /var/log/ibgateway.log 2>&1

kill_ibgateway() {
    if [[ -f /var/run/ibgateway.pid ]]; then
        IB_PID=$(cat /var/run/ibgateway.pid)
        if kill -0 "$IB_PID" 2>/dev/null; then
            echo "Parando IB Gateway (PID $IB_PID)..."
            kill "$IB_PID"
            wait "$IB_PID" 2>/dev/null
        else
            echo "IB Gateway ya parado o PID no valido"
        fi
        rm -f /var/run/ibgateway.pid
    else
        echo "/var/run/ibgateway.pid no existe"
    fi
}

# Arrancar pyroboadvisor
/usr/bin/python3 /home/pyroboadvisor/pyroboadvisor-selfhosting/sample_b.py 2>&1 | tee -a /var/log/pyroboadvisor.log
PYTHON_EXIT_CODE=$?
echo "Pyroboadvisor sale con: $PYTHON_EXIT_CODE" >> /var/log/pyroboadvisor.log
kill_ibgateway

exit $PYTHON_EXIT_CODE

