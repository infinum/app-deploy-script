## This is and example of changelog generator for projects that use JIRA.
## Script calls a python script that uses JIRA package to fetch issues from JIRA API
## Generated changelog is in format
##
## * [<issue number> <issue title>](<link to issue>)
## * [<issue number> <issue title>](<link to issue>)
## ...
##
## depending on how many issue numbers are provided.
## Script can also be configured to parse the task number for the branch name.


## In order to use this script you'll need to follow these steps
##
## 1. Install JIRA package ("pip install jira" will do the trick)
## 2. Create a JIRA token (https://id.atlassian.com/manage-profile/security/api-tokens)
## 3. Open .zshrc (or .bash_profile)
## 4. Add these two lines:
##      export JIRA_EMAIL="<your email on jira>"
##      export JIRA_TOKEN="<your jira token>"
## 5. Save and close .zshrc (or .bash_profile) and restart terminal (or run source ~/.zshrc or source ~/.bash_profile)
##
## Now you should be all set to use this script in your app-deploy.


# Regex used to find task numbers in branch name.
# Replace <project> with prefix used in task numbers on your project.
# Set to "" if you don't want to use this feature.
BRANCH_NAME_TASK_MATCHING_REGEX="(<project>-[0-9]+)"

# Path to python script that will fetch issues from JIRA.
PYTHON_SCRIPT_PATH=".changelog-generator.py"

# JIRA project URL. Used by python script to construct a url to specific issue.
# Replace <project> with your JIRA project name.
JIRA_PROJECT_URL="https://<project>.atlassian.net"

function generate_changelog {

    if [[ -z "$JIRA_EMAIL" || -z "$JIRA_TOKEN" ]]; then
        echo "Missing JIRA_EMAIL or JIRA_TOKEN. Please add it to your .zshrc or .bash_profile configuration file."
        echo

        return
    fi

    local task_numbers=""

    if [[ ! -z $BRANCH_NAME_TASK_MATCHING_REGEX ]]; then
        # Task number contained in branch name
        current_branch=`git rev-parse --abbrev-ref HEAD`
        if [[ $current_branch =~ $BRANCH_NAME_TASK_MATCHING_REGEX ]]; then
            task_numbers=$(printf "%s " "${BASH_REMATCH[@]}")
        fi
    fi

    # Manually enter task number
    if [[ -z $task_numbers ]]; then
        echo
        echo "Enter task number contained in this build, separated by space (e.g., <project>-1234 <project>-5678)."
        echo "For manual changelog entry, leave input empty and press enter."
        echo
        read -r -p "Tasks contained in this build (e.g. <project>-1234 <project>-5678): " task_numbers
    fi

    # Select or edit changelog, edit tasks list and generate again
    while true; do

        if [[ -z "$task_numbers" ]]; then
            break
        fi

        __call_python_script "$task_numbers"

        if [[ -z "$CHANGELOG" ]]; then
            # reason for failure already printed so just break
            break
        fi

        local user_input=""
        __print_generated_changelog
        read -r -p "Press enter to use generated changelog or select one of options (e - edit changelog, a - change task numbers): " user_input

        # Enter
        if [ -z "$user_input" ]; then
            break # Enter pressed -> Exit loop

        # Edit tasks list
        elif [ "$user_input" == "a" ]; then
            echo
            echo "Enter a new list of tasks."
            echo "If an already entered task is needed, please copy it from the list, as the new list will override the existing one."
            echo
            echo "Entered tasks so far: $task_numbers"
            echo
            read -r -p "Tasks contained in this build: " task_numbers
            continue

        # Edit changelog
        elif [ "$user_input" == "e" ]; then
            temp_file=$(mktemp)
            echo "$CHANGELOG" > "$temp_file"
            if [[ $EDITOR ]]; then
                $EDITOR "$temp_file" --wait
            else
                nano "$temp_file"
            fi
            CHANGELOG=$(cat "$temp_file")
            rm "$temp_file"

        # Wrong input
        else
            echo "Oh no! Wrong input... try again!"
        fi
    done
}

function __call_python_script {

    local task_numbers=$1
    local generated_changelog=$(python3 $PYTHON_SCRIPT_PATH "$task_numbers" "$JIRA_PROJECT_URL" "$JIRA_EMAIL" "$JIRA_TOKEN")

    if [[ $generated_changelog == "-99" ]]; then
        echo "JIRA configuration isn't valid. Current configurations:"
        echo "JIRA_PROJECT_URL: $JIRA_PROJECT_URL"
        echo "JIRA_EMAIL: $JIRA_EMAIL"
        echo "JIRA_TOKEN: $JIRA_TOKEN"
        echo
        echo "Please check your configuration and try again."
        echo

        return
    fi

    if [[ $generated_changelog == "-1001" ]]; then
        echo "Failed to connect to JIRA. Please check your configuration and permissions and try again."
        echo

        return
    fi

    if [[ -z $generated_changelog ]]; then
        echo "Generated changelog is empty."
        echo

        return
    fi

    CHANGELOG=$generated_changelog
}

function __print_generated_changelog() {
    echo
    echo "Generated changelog:"
    echo "---------------------------------------------------------------"
    echo "$CHANGELOG"
    echo "---------------------------------------------------------------"
    echo
}
