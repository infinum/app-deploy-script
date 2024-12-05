#################################
#       INIT NEW PROJECT        #
#################################

function init {

    if [ -e "./.deploy-options.sh" ]; then
        echo "Options file already exists."
        echo "If you continue, stored options will be overriden!"
        echo
        read -r -p "Do you want to proceed? [y/n] " c
        if ! [[ ${c} =~ ^(yes|y|Y) ]] || [ -z ${c} ]; then
            exit 1
        fi
    fi

    cat /usr/local/bin/app-deploy-helpers/deploy-options.sh > ./.deploy-options.sh
    echo "The options file was generated successfully!"
    echo "NOTE: Change default values to the project specific."
    echo
}