source /usr/local/bin/.app-deploy-sources/__constants.sh

function __init_deploy_options {
    cat /usr/local/bin/.app-deploy-sources/deploy-options.sh > ./.deploy-options.sh
    echo "The options file was generated successfully!"
    echo "NOTE: Change default values to the project specific."
    echo
}

function __init_changelog_generator {
    cat /usr/local/bin/.app-deploy-sources/changelog-generator.sh > ./.changelog-generator.sh
    echo "Changelog generator file was generated successfully!"
    echo "NOTE: Change default implementation to the project specific."
    echo "      Examples can be found https://github.com/infinum/app-deploy-script/tree/master/examples/changelog_generator."
    echo
}

#################################
#       INIT NEW PROJECT        #
#################################

function __init {

    __header_print

    if [ -e "./.deploy-options.sh" ]; then
        echo "Options file already exists."
        echo "If you continue, stored options will be overridden!"
        echo
        read -r -p "Do you want to proceed? [y/n] " c
        if [[ ${c} =~ ^(yes|y|Y) ]] || [ -z ${c} ]; then
           __init_deploy_options
        fi
    else
        __init_deploy_options
    fi

    if [ -e "./.changelog-generator.sh" ]; then
        echo "Changelog generator file already exists."
        echo "If you continue, current implementation will be overridden!"
        echo
        read -r -p "Do you want to proceed? [y/n] " c
        if [[ ${c} =~ ^(yes|y|Y) ]] || [ -z ${c} ]; then
            __init_changelog_generator
        fi
    else
        read -r -p "Add changelog generator file? [y/n] " c
        if [[ ${c} =~ ^(yes|y|Y) ]] || [ -z ${c} ]; then
            __init_changelog_generator
        fi
    fi
}
