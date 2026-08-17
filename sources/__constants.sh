#################################
#           CONSTANTS           #
#################################

function __header_print {
    echo
    echo "###############################################################"
    echo "#                         DEPLOY SCRIPT                       #"
    echo "#                                                             #"
    echo "#                   Copyright (c) 2024 Infinum.               #"
    echo "###############################################################"
    echo
}

function __clear_console {
    if $use_automatic_console_clean ; then
        clear
    fi
}

function __legacy_install_warning {
    echo
    echo "NOTE: This manual installation of app-deploy is deprecated."
    echo "Run 'app-deploy --migrate' to switch to the Homebrew-managed install."
    echo
}

function __update_removed_notice {
    echo
    if [ "$APP_DEPLOY_LEGACY_INSTALL" == "true" ]; then
        echo "'--update' is no longer supported."
        echo "Run 'app-deploy --migrate' to move to Homebrew - updates are then handled via 'brew upgrade app-deploy'."
    else
        echo "'--update' is no longer supported. Use 'brew upgrade app-deploy' instead."
    fi
    echo
    exit 1
}
TRIGGER_TAG_PREFIX="ci/"
TRIGGER_TAG_SUFIX="$(date +%Y-%m-%dT%H-%M-%S)"
TRIGGER_TAG_SUFIX_REGEX=([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2})
PLATFORM_ANDROID_APK="platform_android_apk"
PLATFORM_ANDROID_AAB="platform_android_aab"
PLATFORM_IOS="platform_ios"
BUNDLE_TOOL_VERSION="1.17.2"