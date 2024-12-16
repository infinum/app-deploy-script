#!/usr/bin/env bash

source ./.deploy-options.sh

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

# Use global variables at your own risk as this can be overridden in the future.
set -e
bold=$(tput bold)
normal=$(tput sgr0)

VERSION="1.1.1"

#################################
#             MAIN              #
#################################

# Private part of the script...
#
# In general, you don't have to edit
# this part of the script but feel free
# to edit any part of it as suits your needs.

function main {

    # BASE INFO
    # commit, tag, synced head,...
    initial_checkup

    # CREATE TAG

    deploy_options
    input_to_tags
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
            current_branch=`git rev-parse --abbrev-ref HEAD`
            echo "Pushing..."
            git push origin "$current_branch"
        else
            read -r -p "Do you want to push it? [y/n] " push_to_git
            if [[ ${push_to_git} =~ ^(yes|y|Y) ]] || [ -z ${push_to_git} ]; then
                current_branch=`git rev-parse --abbrev-ref HEAD`
                echo "Pushing..."
                git push origin "$current_branch"
            else
                echo "Aborting."
                exit 3   
            fi
        fi
    fi
}

function input_to_tags {

    # Parse all selected options
    IFS=', ' read -r -a environments_array <<< "$target_selection"

    environments_to_build=()

    for environment in "${environments_array[@]}"; do
        if [ ${environment} -le $((${#environments[@]} - 1)) -a ${environment} -ge 0 ]; then
            environments_to_build+=("${environments[${environment}]}")
        else
            echo "Error: You chose wrong, young Jedi. This is the end of your path..."
            exit 4
        fi
    done
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
    tags_to_deploy=()
    for target in "${environments_to_build[@]}"; do
        tags_to_deploy+=("$target/v$appversion-$tags_count")
    done

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

    tag_message_added=0
    for tag in "${tags_to_deploy[@]}"; do

        if [ ${tag_message_added} -eq 1 ]; then
            TAG=`git describe --exact-match`
            CHANGELOG=`git show -s --format=%N ${TAG} | tail -n +4`
            git tag -a "$tag" -m "${CHANGELOG}"
        else
            git tag -a "$tag"
            tag_message_added=1
        fi
    done
}

function push_tag_and_start_deploy {

    changelog_message=`git show -s --format=%N ${tag} | tail -n +4`

    if ! $enable_final_confirmation ; then
        push_tag
    fi

    echo
    echo "###############################################################"
    echo "#                          DEPLOY                             #"
    echo "###############################################################"
    echo
    echo "---------------------------------------------------------------"
    echo "                      ~ CONFIGURATION ~   "
    echo
    echo "Version: ${bold}v$appversion-$tags_count${normal}"        
    for tag in "${tags_to_deploy[@]}"; do
        echo "Tag: ${bold}$tag${normal}"
    done
    echo
    echo "Changelog:"
    echo "${bold}$changelog_message${normal}"
    echo "---------------------------------------------------------------"
    echo
    read -r -p "Is configuration correct for the CI deployment? [y or enter / n] " response
    echo

    if [[ ${response} =~ ^(no|n|N) ]]; then
        echo "Aborting."
        for tag in "${tags_to_deploy[@]}"; do
            git tag -d "$tag"
        done
        exit 6
    fi

    push_tag
}

function push_tag {
    # Push if everything is ok!
    if [ $? -eq 0 ]; then
        echo
        echo "------------------------------------------------------------"
        echo
        for tag in "${tags_to_deploy[@]}"; do
            # Push if everything is ok!
            echo "Tag ${bold}${tag}${normal} added. Pushing tag ..."
            git push origin "$tag"
        done
        echo
        echo "============================================================"
        echo "DEPLOY TAG SUCCESSFULLY ADDED!"
        echo "CHECK YOUR CI FOR THE BUILD STATUS"
        echo "============================================================"
        echo
        exit 0
    else
        echo
        echo "------------------------------------------------------------"
        echo "Failed to add tag. Aborting."
        echo "------------------------------------------------------------"
        exit 7
    fi
}

#################################
#            UPDATE             #
#################################

function script_auto_update {
    echo 
    echo "Please wait until main script is finished with updating..."
    echo
    echo "Fetching new data..."
    if [ ! -d ".app_deploy_tmp" ]; then
        mkdir .app_deploy_tmp
    fi
    git clone --quiet https://github.com/infinum/app-deploy-script.git .app_deploy_tmp
    echo "Updating..."
    cat .app_deploy_tmp/app-deploy.sh > /usr/local/bin/app-deploy
    echo "Cleaning temporary files..."
    rm -rf .app_deploy_tmp
    echo "Updating finished!"
    exit 0
}

#################################
#       START EVERYTHING        #
#################################

if $use_automatic_console_clean ; then
    clear
fi
echo
echo "###############################################################"
echo "#                         DEPLOY SCRIPT                       #"
echo "#                                                             #"
echo "#                   Copyright (c) 2020 Infinum.               #"
echo "###############################################################"
echo

if  [ "$1" == '--update' ] ; then
    script_auto_update
elif [ "$1" == '-v' ] || [ "$1" == '--version' ] ; then
    echo "$VERSION"
else
    main
fi