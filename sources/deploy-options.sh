#!/usr/bin/env bash

# Defines the version of workflow supported by this script. Currently, two versions are available, v1 and v2.
#
# v1 #
# An old workflow where the local script will ask you for the app version. 
# The script will generate the next build number that can be used on the CI/CD.
# Each selected environment will get its tag, e.g., for Staging and UAT, you'll get two tags internal-staging/v1.0.0-1 and internal-uat/v1.0.0-1
#
# v2 #
# New workflow, where the local script is used only as a CI/CD trigger.
# The script will not generate a build number or ask you for the app version.
# Each selected environment is concatenated into one tag. The tag will always start with `ci/` and end with `/{timestamp}.` E.g., ci/internal-staging/internal-uat/{timestamp}
#
# By default, this option is set to new workflow - v2
script_version=v2
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
    echo "[0] Staging"
    echo "[1] UAT"
    echo "[2] Production"
    echo
    echo "=================="
    echo
    echo "---------"
    echo "| STORE |"
    echo "---------"
    echo
    echo "[3] App/Play Store"
    echo
    echo "Enter number written in the square brackets."
    echo "To run multiple targets, write multiple numbers separated by empty space (e.g. Enter targets: 0 3)"
    read -r -p "Enter targets: " target_selection

    # Array for creating first part of the tag.
    # Should be in sync with options shown to the user.
    environments=("internal-staging" "internal-uat" "internal-production" "store")
}
