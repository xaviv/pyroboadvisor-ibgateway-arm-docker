# Ejecutar para obtener el checksum sha256 de pyroboadvisor
curl -sSOL "https://github.com/daradija/pyroboadvisor/archive/refs/heads/selfhosting.zip"
test -f selfhosting.zip && sha256sum selfhosting.zip; rm -f selfhosting.zip