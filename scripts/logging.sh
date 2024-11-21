#!/bin/bash

GREEN='\e[32m'
RED='\e[31m'
YELLOW='\e[33m'
RESET='\e[0m'

LOGFILE="/var/log/video_stream.log"

log() {
    local LEVEL=$1
    shift
    local MESSAGE="$@"
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${TIMESTAMP} [${LEVEL}] ${MESSAGE}" | tee -a "$LOGFILE"
}


log_info() {
    log "INFO" "${GREEN}$@${RESET}"
}

log_warning() {
    log "WARNING" "${YELLOW}$@${RESET}"
}

log_error() {
    log "ERROR" "${RED}$@${RESET}"
}