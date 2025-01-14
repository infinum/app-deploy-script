#################################
#            DEPLOY             #
#################################

function __push_tag_and_start_deploy {

    changelog_message=`git show -s --format=%N ${tag} | tail -n +4`

    if ! $enable_final_confirmation ; then
        __push_tag
    fi

    echo
    echo "###############################################################"
    echo "#                          DEPLOY                             #"
    echo "###############################################################"
    echo
    echo "---------------------------------------------------------------"
    echo "                      ~ CONFIGURATION ~   "
    echo
    if [ -n "$appversion" ]; then
        echo "Version: ${bold}v$appversion-$tags_count${normal}"        
    fi
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

    __push_tag
}

function __push_tag {
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