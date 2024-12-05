#################################
#          CREATE TAG           #
#################################

# Parse all selected options
function __input_to_tags {

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

# Generate app version and build number
function __create_app_version_and_build_number {

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

# Changelog
function __generate_tag_and_changelog {

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