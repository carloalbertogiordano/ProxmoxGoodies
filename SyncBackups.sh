#!/bin/bash

# Variabili configurabili
SRC="/mnt/pve/nfs-vms/dump/"          # Percorso sorgente
DST="/mnt/BackupHDD/clonedBackups/"   # Percorso destinazione
SERVICE_NAME="syncBackups"            # Nome del servizio
LOG_FILE="/var/log/${SERVICE_NAME}.log"
ERROR_LOG_FILE="/var/log/${SERVICE_NAME}_error.log"
SCRIPT_PATH="/usr/local/bin/${SERVICE_NAME}.sh"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

# Funzione per creare lo script di sincronizzazione
create_sync_script() {
    echo "Creazione dello script di sincronizzazione in ${SCRIPT_PATH}..."
    cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

# Sorgente e destinazione
SRC="${SRC}"
DST="${DST}"

# Funzione per monitorare l'inattività
wait_for_inactivity() {
    while inotifywait -r -e modify,create,delete,move --timeout 1800 "\$SRC"; do
        echo "Modifiche rilevate, resetto il timer di 30 minuti..."
    done
    echo "Nessuna modifica negli ultimi 30 minuti. Avvio il backup..."
}

# Ciclo continuo per monitorare e sincronizzare
while true; do
    wait_for_inactivity
    rsync -aAX --delete --sparse "\$SRC" "\$DST" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
done
EOF

    chmod +x "$SCRIPT_PATH"
    echo "Script creato e reso eseguibile."
}

# Funzione per creare il file di servizio systemd
create_service_file() {
    echo "Creazione del file di servizio in ${SERVICE_PATH}..."
    cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=Backup automatico basato su inattività
After=network.target

[Service]
Type=simple
ExecStart=${SCRIPT_PATH}
Restart=always
RestartSec=10

# Log su file
StandardOutput=append:${LOG_FILE}
StandardError=append:${ERROR_LOG_FILE}

[Install]
WantedBy=multi-user.target
EOF

    echo "File di servizio creato."
}

# Funzione per configurare i file di log
configure_logs() {
    echo "Configurazione dei file di log..."
    touch "$LOG_FILE" "$ERROR_LOG_FILE"
    chmod 644 "$LOG_FILE" "$ERROR_LOG_FILE"
    echo "File di log configurati."
}

# Funzione per abilitare e avviare il servizio
enable_and_start_service() {
    echo "Ricarico systemd, abilito e avvio il servizio..."
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME.service"
    systemctl start "$SERVICE_NAME.service"
    echo "Servizio avviato e abilitato all'avvio automatico."
}

# Funzione principale
main() {
    echo "Installazione del servizio ${SERVICE_NAME}..."
    create_sync_script
    create_service_file
    configure_logs
    enable_and_start_service
    echo "Installazione completata."
}

# Esecuzione dello script
main
