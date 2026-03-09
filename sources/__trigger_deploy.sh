source /usr/local/bin/.app-deploy-sources/helpers/__base_tag_handling.sh
source /usr/local/bin/.app-deploy-sources/helpers/__deploy_tags.sh
source /usr/local/bin/.app-deploy-sources/helpers/__initial_checkup.sh

#################################
#     DEPLOYMENT TRIGGER TAG    #
#################################

# Private part of the script...
#
# In general, you don't have to edit
# this part of the script but feel free
# to edit any part of it as suits your needs.

bold=$(tput bold)
normal=$(tput sgr0)

function __parse_trigger_cli_flags {
    CLI_CHANGELOG=""
    CLI_TARGETS=""

    [ "${1}" == "trigger" ] && shift

    while getopts "t:m:" opt; do
        case "$opt" in
            t) CLI_TARGETS="$OPTARG" ;;
            m) CLI_CHANGELOG="$OPTARG" ;;
            *) echo "Error: Invalid option"; exit 1 ;;
        esac
    done
}

function __trigger_deploy {

    __parse_trigger_cli_flags "$@"

    __header_print

    # BASE INFO
    # commit, tag, synced head,...
    __initial_checkup

    # CREATE TAG

    if [ -n "$CLI_TARGETS" ]; then
        deploy_options <<< "$CLI_TARGETS" # Get from .deploy-options.sh, setup per project
    else
        deploy_options # Get from .deploy-options.sh, setup per project
    fi
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