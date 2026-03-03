#!/usr/bin/env bash

source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/__help.sh

cli_changelog=""
cli_targets=""

if [ -z "$1" ] || [ "$1" == 'trigger' ] ; then
    # Parse optional CLI flags for the trigger command
    args=("$@")
    [ "${args[0]}" == "trigger" ] && i=1 || i=0
    while [ $i -lt ${#args[@]} ]; do
        case "${args[$i]}" in
            -m)
                next_index=$((i+1))
                if [ $next_index -ge ${#args[@]} ] || [[ "${args[$next_index]}" == -* ]]; then
                    echo
                    echo "Missing value for -m flag. Please provide a changelog message after -m."
                    echo
                    exit 29
                fi
                i=$next_index
                cli_changelog="${args[$i]}"
                ;;
            -t)
                next_index=$((i+1))
                if [ $next_index -ge ${#args[@]} ] || [[ "${args[$next_index]}" == -* ]]; then
                    echo
                    echo "Missing value for -t flag. Please provide target environments after -t."
                    echo
                    exit 29
                fi
                i=$next_index
                cli_targets="${args[$i]}"
                ;;
            *)
                echo
                echo "Unknown flag: ${args[$i]}"
                echo
                exit 29
                ;;
        esac
        i=$((i+1))
    done

    source ./.deploy-options.sh
    source /usr/local/bin/.app-deploy-sources/__trigger_deploy.sh
fi
source /usr/local/bin/.app-deploy-sources/__auto_update.sh
source /usr/local/bin/.app-deploy-sources/__init.sh
source /usr/local/bin/.app-deploy-sources/__env_extractor.sh
source /usr/local/bin/.app-deploy-sources/__build_tagging.sh

###############################################################
#                       DEPLOY SCRIPT                         #
#                                                             #
#          Script used for creating the specific              #
#        tag used for triggering the CI deployment            #
#                                                             #
#                                                             #
#                Prepared by Jasmin Abou Aldan                #
#       Copyright (c) 2024 Infinum. All rights reserved.      #
###############################################################

# Use global variables at your own risk as this can be overridden in the future.
set -e

VERSION="2.0.1"

#################################
#       START EVERYTHING        #
#################################

if [ "$1" == '-h' ] || [ "$1" == '--help' ] ; then
    __help
elif [ "$1" == '-v' ] || [ "$1" == '--version' ] ; then
    echo "app-deploy $VERSION"
elif [ "$1" == '--update' ] ; then
    __clear_console
    __script_auto_update
elif [ "$1" == 'init' ] ; then
    __clear_console
    __init
elif [ -z "$1" ] || [ "$1" == 'trigger' ] ; then # Empty input or "trigger"
    __clear_console
    __trigger_deploy
elif [ "$1" == 'environments' ] ; then
    __env_extractor "$2"
elif [ "$1" == 'tagging' ]; then
    __build_tagging "$@"
else
    echo
    echo "Unsuported command!"
    echo
    exit 29
fi
