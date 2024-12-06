source /usr/local/bin/.app-deploy-sources/__constants.sh

#################################
#     ENVIRONMENT EXTRACTOR     #
#################################

function __env_extractor {

    # Check if input is valid
    if [ -z "$1" ] ; then 
        echo "Missing input value!"
        echo
        echo "Usage: app-deploy environments input"
        echo "- input: a value from which 'environments' command shoudl extract data. Should be trigger tag generated by this script."
        exit 1
    fi

    if [[ $1 =~ ^$TRIGGER_TAG_PREFIX(.+)/$TRIGGER_TAG_SUFIX_REGEX$ ]]; then
        paths="${BASH_REMATCH[1]}"

        # Split the captured paths into individual words
        IFS='/' read -ra words <<< "$paths"
        echo "$(IFS=$'\n'; echo "${words[*]}")"
    else
        echo
        echo "Incorrect input value."
        echo
        echo "The environment can only be extracted from the official trigger tag."
        echo
        echo "Please use this script for generating the trigger tag, or use the tag in the format:"
        echo "prefix: ci/"
        echo "environments: env1/env2/..."
        echo "sufix: /timestamp where timestamp should be in the format of +%Y-%m-%dT%H-%M-%S (2024-12-06T11-24-53)"
        echo "EXAMPLE: ci/env1/env2/2024-12-06T11-24-53"
    fi
}