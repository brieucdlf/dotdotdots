#!/bin/sh

COLLECTIONS_PATH="$HOME/dotdotdots/scripts/sflow_smach/sflow-api"

usage() {
  echo "Usage: ./mongo-json-inport.sh [-h|-help] [-c COLLECTION_PATH|-c=COLLECTIONS_PATH|--collections_path COLLECTION_PATH|--collections_path=COLLECTIONS_PATH]"
  echo
  echo "OPTIONS:"
  echo -e "   -c, --path\t absolute path where the collections are. DEFAULT_PATH: $COLLECTIONS_PATH"
  echo -e "   -h, --help\t prints the help"
  echo
  echo "EXAMPLES:"
  echo "   ./mongo-json-import"
  echo "   ./mongo-json-import -h"
  echo "   ./mongo-json-import --help"
  echo "   ./mongo-json-import -c=<ABSOLUTE PATH OF YOUR COLLECTIONS>"
  echo "   ./mongo-json-import -collections_path=<ABSOLUTE PATH OF YOUR COLLECTIONS>"
  exit 1
}

echo_error() {
  echo -e "\033[0;31m$1\033[0m"
}

checking_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h | --help)
        usage
        exit 0
      ;;
      -c=* | --collections_path=*)
        COLLECTIONS_PATH="${1#*=}"
      ;;
      *)
        echo_error "Unknown option '$1'"
        usage
      ;;
    esac
    shift
  done
}

import_collections() {
  echo "$COLLECTIONS_PATH"

  for entry in "$COLLECTIONS_PATH"/*
    do
      echo
      echo "Add $entry into database"
      mongoimport -d startupflow "$entry"
      echo
    done
}

checking_arguments $@
import_collections
