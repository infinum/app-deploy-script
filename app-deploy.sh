#!/usr/bin/env bash

if [ -z "$1" ] || [ "$1" == 'trigger' ] ; then
    source ./.deploy-options.sh
    source /usr/local/bin/.app-deploy-sources/__trigger_deploy.sh
fi
source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/__auto_update.sh
source /usr/local/bin/.app-deploy-sources/__init.sh
source /usr/local/bin/.app-deploy-sources/__initial_checkup.sh
source /usr/local/bin/.app-deploy-sources/__base_tag_handling.sh
source /usr/local/bin/.app-deploy-sources/__deploy_tags.sh
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

#################################
#       START EVERYTHING        #
#################################

if [ "$1" == '--update' ] ; then
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
