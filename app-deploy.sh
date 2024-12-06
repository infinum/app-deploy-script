#!/usr/bin/env bash

source ./.deploy-options.sh
source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/__auto_update.sh
source /usr/local/bin/.app-deploy-sources/__init.sh
source /usr/local/bin/.app-deploy-sources/__initial_checkup.sh
source /usr/local/bin/.app-deploy-sources/__base_tag_handling.sh
source /usr/local/bin/.app-deploy-sources/__deploy_tags.sh
source /usr/local/bin/.app-deploy-sources/__env_extractor.sh

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
bold=$(tput bold)
normal=$(tput sgr0)

#################################
#             MAIN              #
#################################

# Private part of the script...
#
# In general, you don't have to edit
# this part of the script but feel free
# to edit any part of it as suits your needs.

function main {

    __header_print

    # BASE INFO
    # commit, tag, synced head,...
    __initial_checkup

    # CREATE TAG

    deploy_options # Get from .deploy-options.sh, setup per project
    __input_to_tags

    if [ -z "$script_version" ] || [ "$script_version" == "v1" ]; then
        __create_app_version_and_build_number
    elif [ "$script_version" == "v2" ]; then
        __create_trigger_ci_timestamp_tag
    fi

    # CREATE CHANGELOG

    __generate_tag_and_changelog
        
    # DEPLOY
        
    __push_tag_and_start_deploy
}

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
    main
elif [ "$1" == 'environments' ] ; then
    echo $(__env_extractor "$2")
else
    echo
    echo "Unsuported command!"
    echo
    exit 0
fi
