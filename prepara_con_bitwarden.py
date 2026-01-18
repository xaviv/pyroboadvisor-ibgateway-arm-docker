import os
import argparse
from vault.bitwarden import VaultwardenClient  

from pathlib import Path

def update_ini(path, updates: dict):
    lines = []
    ini_path = Path(path)

    for line in ini_path.read_text().splitlines():
        key, sep, value = line.partition("=")
        if key in updates:
            lines.append(f"{key}={updates[key]}")
        else:
            lines.append(line)

    ini_path.write_text("\n".join(lines) + "\n")

def prepara_fichero_config(bitwarden_url):
    vault = VaultwardenClient(bitwarden_url)

    username, password = vault.get_credentials("interactivebrokers.ie")

    update_ini(
        "/opt/config.ini",
        {
            "IbLoginId": username,
            "IbPassword": password
        }
    )

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--bitwarden-url", dest="bitwarden_url")
    args = parser.parse_args()
    if args.bitwarden_url:
        prepara_fichero_config(args.bitwarden_url)