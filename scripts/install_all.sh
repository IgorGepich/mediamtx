#!/bin/bash

# Include logging functions
source ./logging.sh

SCRIPT_PATH=$(realpath "$0")
LOGFILE="setup_main.log" # Log file for the main script

log_info "Starting the main setup process." | tee -a "$LOGFILE"

log_info "Starting the stream setup script..." | tee -a "$LOGFILE"
if ./stream_setup.sh 2>&1 | tee -a "$LOGFILE"; then
    log_info "Stream setup completed successfully." | tee -a "$LOGFILE"
else
    log_error "Stream setup failed." | tee -a "$LOGFILE"
    exit 1
fi

log_info "Starting the hostname change script..." | tee -a "$LOGFILE"
if ./change_hostname.sh 2>&1 | tee -a "$LOGFILE"; then
    log_info "Hostname changing completed successfully." | tee -a "$LOGFILE"
else
    log_error "Hostname change failed." | tee -a "$LOGFILE"
    exit 1
fi

log_info "Starting the access point setup script..." | tee -a "$LOGFILE"
if ./rpi_access_point_setup.sh 2>&1 | tee -a "$LOGFILE"; then
    log_info "Access point setup completed successfully." | tee -a "$LOGFILE"
else
    log_error "Access point setup failed." | tee -a "$LOGFILE"
    exit 1
fi

log_info "All scripts completed successfully!" | tee -a "$LOGFILE"

log_info "Deleting the main script: $SCRIPT_PATH..." | tee -a "$LOGFILE"
(
    sleep 2
    rm -- "$SCRIPT_PATH"
) &

cd ..