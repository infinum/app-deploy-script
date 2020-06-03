#!/usr/bin/env bash

###############################################################
#                       DEPLOY SCRIPT                         #
#                                                             #
#          Script used for creating the specific              #
#        tag used for triggering the CI deployment            #
#                                                             #
#               End tag should look like this:                #
#                  internal-all/v1.0.0-1234                   #
#                                                             #
#                Prepared by Jasmin Abou Aldan                #
#       Copyright (c) 2020 Infinum. All rights reserved.      #
###############################################################

set -e
bold=$(tput bold)
normal=$(tput sgr0)
enable_automatic_commit_push=true


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

#################################
#             MAIN              #
#################################

# Private part of the script...
#
# In general, you don't have to edit
# this part of the script but feel free
# to edit any part of it as suits your needs.

function main {

    clear
    echo
    echo "###############################################################"
    echo "#                         DEPLOY SCRIPT                       #"
    echo "#                                                             #"
    echo "#                   Copyright (c) 2020 Infinum.               #"
    echo "###############################################################"
    echo

    # BASE INFO
    # commit, tag, synced head,...
    initial_checkup

    # CREATE TAG

    deploy_options
    create_app_version_and_build_number

    # CREATE CHANGELOG

    generate_tag_and_changelog
        
    # DEPLOY
        
    push_tag_and_start_deploy
}


#################################
#           HELPERS             #
#################################

function initial_checkup {

    echo
    echo "###############################################################"
    echo "#                      COMMIT CHECK                           #"
    echo "###############################################################"
    echo

    if [ $# -gt 1 ] || [ "$1" == '-h' ] || [ "$1" == '--help' ] || [ "$1" == 'help' ]; then
        echo "Usage: $0 [optional-commit-hash]"
        exit 1
    fi

    if [ $# -eq 1 ]; then
        commit="$1"
    else
        commit=`git rev-parse --short HEAD`
    fi

    commit_message=`git log --format=%B -n 1 ${commit}`

    if [ $? -ne 0 ]; then
        echo "Failed to get message for commit '$commit'. Aborting."
        exit 2
    fi
    
    echo "---------------------------------------------------------------"
    echo "Targeting commit: ${bold}$commit${normal}"
    echo "---------------------------------------------------------------"
    echo "$commit_message"
    echo "---------------------------------------------------------------"

    remote_branches=`git branch -r --contains ${commit}`
    if [ $? -ne 0 ] || [ -z "$remote_branches" ]; then
        echo
        echo "Commit '$commit' not found on any remote branch."
	        if $enable_automatic_commit_push ; then
	        read -r -p "Do you want to push it? [y/n] " push_to_git
	        if [[ ${push_to_git} =~ ^(yes|y|Y) ]] || [ -z ${push_to_git} ]; then
	            current_branch=`git rev-parse --abbrev-ref HEAD`
	            echo "Pushing..."
	            git push origin "$current_branch"
	        else
	            echo "Aborting."
	            exit 3
	        fi
        else
        	echo "Aborting."
	        exit 3
        fi
    fi
}

function create_app_version_and_build_number {

    echo
    echo "###############################################################"
    echo "#                         APP VERSION                         #"
    echo "###############################################################"
    echo

    # App version number
    last_known_tag=`git describe --abbrev=0 --tags | sed -E 's/.*v([0-9]*\.?[0-9]*\.?[0-9]*)(-.*)?/\1/'`

    if [ -z "$last_known_tag" ]
    then
        read -r -p "Enter current app version (e.g. 1.0.0): " appversion
    else
        read -r -p "Press enter to use last known version: ${bold}$last_known_tag${normal}. (or enter different version) " new_version
        [ -z "$new_version" ] && appversion=$last_known_tag || appversion=$new_version
    fi

    if ! [[ "$appversion" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then 
        echo "App version is in wrong format (use M.m.p format, e.g. 1.0.0). Aborting..."
        exit 5
    fi

    # Build number

    echo "Getting next build number..."

    tags_count=`git ls-remote --t --refs -q | grep -o -E '[[:<:]]\d+(\n|$)' | sort -nr | head -n1`

    if [ -z "$tags_count" ]; then
        tags_count=0
    else
        tags_count=$((tags_count+1))
    fi

    # Create tag name internal{-TargetX}/vM.m.p-{number of commits}. E.g. internal-all/v1.0.0-1234
    tag="$target/v$appversion-$tags_count"

    echo
    echo "Next app version is: ${bold}v$appversion-$tags_count${normal}"
    sleep 1
}

function generate_tag_and_changelog {

    echo
    echo "###############################################################"
    echo "#                          CHANGELOG                          #"
    echo "###############################################################"
    echo
    echo "------------------------------------------------------------"
    echo "Enter changelog message..."
    echo "------------------------------------------------------------"
    sleep 1
    
    git tag -a "$tag"
}

function push_tag_and_start_deploy {

    changelog_message=`git show -s --format=%N ${tag} | tail -n +4`

    echo
    echo "###############################################################"
    echo "#                          DEPLOY                             #"
    echo "###############################################################"
    echo
    echo "---------------------------------------------------------------"
    echo "                      ~ CONFIGURATION ~   "
    echo
    echo "Target: ${bold}$target_selection. $target${normal}"
    echo "Version: ${bold}v$appversion-$tags_count${normal}"
    echo "Tag: ${bold}$tag${normal}"
    echo
    echo "Changelog:"
    echo "${bold}$changelog_message${normal}"
    echo "---------------------------------------------------------------"
    echo
    read -r -p "Is configuration correct for the CI deployment? [y/n] " response
    echo

    if [[ ${response} =~ ^(no|n|N) ]] || [ -z ${response} ]; then
        git tag -d "$tag"
        echo "Aborting."
        exit 6
    fi

    # Push if everything is ok!
    if [ $? -eq 0 ]; then
        echo
        echo "------------------------------------------------------------"
        echo "Tag added. Pushing tags ..."
        echo        
        git push origin "$tag"
        echo
        echo "============================================================"
        echo "DEPLOY TAG SUCCESSFULLY ADDED!"
        echo "CHECK YOUR CI FOR THE BUILD STATUS"
        echo "============================================================"
        echo
    else
        echo
        echo "------------------------------------------------------------"
        echo "Failed to add tag. Aborting."
        echo "------------------------------------------------------------"
        exit 7
    fi
}

#################################
#       START EVERYTHING        #
#################################

main