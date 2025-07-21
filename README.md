## Objetivo

Contenerizar pyroboadvisor (https://pyroboadvisor.com) y sus dependencias, incluyendo IB gateway, permitiendo alojarlo en un entorno doméstico o privado.

## Requisitos

- Como usuario, espero una interfaz sencilla que permita configurar mi cuenta IBKR y licencia pyroboadvisor, modo vivo (live) y simulación (paper) y otros parámetros de funcionamiento de pyroboadvisor
- Pretendo utilizar ARM64 para poder alojar el contenedor en dispositivos económicos como SBCs ej: raspberry (ARM) o orangepi (Rockchip), o NAS ej: Synology.
 - Como usuario, espero que el docker se reinicie diariamente y se auto-autentique. Espero usar 2FA y controlar la autenticación desde la app de IB instalada en el móvil
- A diferencia de otros dockers con el software de IBKR, la API no se expone fuera del docker y será utilizada internamente

## Notas de implementación

- La versión latest de IBgateway está actualizada a java 17, pero requiere de javafx. Puede encontrarse una distribución de JDK 17 LTS en https://bell-sw.com/pages/downloads/#jdk-17-lts. Es necesario usar la versión full JDK
- Utilizo novnc para tener acceso al escritorio x11 desde web
- Utilizo IBC para automatizar el arranque
- Como base de docker uso ubuntu en arm64. La instalación de IBgateway debe realizarse fuera del contenedor
- Utilizo un makefile como base para construir, ejecutar el docker y otras tareas de mantenimiento
- En la carpeta assets hay las plantillas de los archivos de configuración a mover a la carpeta private
- Creada una rama selfhosting en el repositorio de pyroboadvisor para su ejecución desatendida

## Pendiente
- App en flask para poder ver estado, consultar logs y poder cambiar parametros
- Aligerar el docker, reduciendo componentes innecesarios

## Referencias útiles

- Docker existente para IBKR: https://github.com/extrange/ibkr-docker
- Componente IBC: https://github.com/IbcAlpha/IBC/blob/3.23.0/resources/userguide.pdf
- IB gateway info: https://www.interactivebrokers.com/lib/cstools/faq/#/content/41571362 (links broken)
- IB gateway download: https://www.interactivebrokers.com/en/trading/ibgateway-stable.php
- Puertos a usar: https://www.interactivebrokers.com/en/?f=%2Fen%2Fgeneral%2Ftws-notes-954.php
		- API: IB gateway live (4001) o IB gateway paper (4002)
		- noVNC: 6800
- Google groups para TWS: https://groups.io/g/twsapi/topic/install_tws_or_ib_gateway_on/25165590?page=2
- Google groups para IBC: https://groups.io/g/ibcalpha/message/2378?p=%2C%2C%2C20%2C0%2C0%2C0%3A%3Acreated%2C%2Carm%2C20%2C2%2C0%2C110136835