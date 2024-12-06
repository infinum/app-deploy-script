#################################
#           CONSTANTS           #
#################################

function __header_print() {
    echo
    echo "###############################################################"
    echo "#                         DEPLOY SCRIPT                       #"
    echo "#                                                             #"
    echo "#                   Copyright (c) 2024 Infinum.               #"
    echo "###############################################################"
    echo
}

TRIGGER_TAG_PREFIX="ci/"
TRIGGER_TAG_SUFIX="$(date +%Y-%m-%dT%H-%M-%S)"
TRIGGER_TAG_SUFIX_REGEX=([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2})