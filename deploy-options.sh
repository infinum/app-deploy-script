#!/usr/bin/env bash

# If enabled, console will be cleared on every script run.
# By default, this option is enabled
use_automatic_console_clean=true
# If enabled, not pushed commits will be pushed automatically without confirmation dialog.
# By default, this option is disabled
enable_automatic_commit_push=false
# If enabled, confirmation dialog with deploy summary will be presented.
# By default, this option is enabled
enable_final_confirmation=true

#########################################################
#                     DEPLOY OPTIONS                    #
#                                                       #
# Part of script that should be edited by the user.     #
#                                                       #
# You can add/remove/edit targets that you want to use  #
# for the deployment.                                   #
#                                                       #
# This will generate first part of tag.                 #
#########################################################

## Used for the option select by the user
## And for generating first part of the tag.
## If option is added to the "Select target"
## same option should be added under the 
## if/else logic for creating the first part.

## WARNING: This file should be in the same folder as `app-deploy.sh` file

function deploy_options {

    # Options shown to the user

    echo
    echo "###############################################################"
    echo "#                  DEPLOY TARGET SELECTION                    #"
    echo "###############################################################"
    echo
    echo "--------------"
    echo "| TryOutApps |"
    echo "--------------"
    echo
    echo "[0] All"
    echo "[1] Staging"
    echo "[2] UAT"
    echo "[3] Production"
    echo
    echo "=================="
    echo
    echo "---------------------"
    echo "| APP STORE CONNECT |"
    echo "---------------------"
    echo
    echo "[4] App Store"
    echo
    read -r -p "Enter number in square brackets: " target_selection
    # erase_lines

    # Logic for creating first part of the tag.
    # Should be in sync with options shown to the user.

    if [ ${target_selection} -eq 0 ]; then
        target="internal-all"
    elif [ ${target_selection} -eq 1 ]; then
        target="internal-staging"
    elif [ ${target_selection} -eq 2 ]; then
        target="internal-uat"
    elif [ ${target_selection} -eq 3 ]; then
        target="internal-production"
    elif [ ${target_selection} -eq 4 ]; then
        target="appstore"
    else
        echo "Wrong target index. Aborting..."
        exit 4
    fi
}
