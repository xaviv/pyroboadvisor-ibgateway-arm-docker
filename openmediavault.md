# Instrucciones usando openmediavault 7

En el menú Services / Compose / Files:
![Ejemplo de dockerfile](assets/omv_dockerfile.png)

Usa el ejemplo de ![Docker compose file](Dockerfile.yml)

En el menú Schedule puedes programar el arranque diario:
![Ejemplo de tarea programada](assets/omv_crontask.png)
Nota que el arranque debe ser mediante docker compose para que utilice la misma configuración que la definida en el docker compose file
