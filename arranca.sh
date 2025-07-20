#!/bin/bash

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
exec ./gatewaystart.sh
