#################################
#         INITIAL CHECK         #
#################################

# Check commit, tag, synced head,...
# Report any uncommited changes, unpushed commits, etc..
function __initial_checkup {

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