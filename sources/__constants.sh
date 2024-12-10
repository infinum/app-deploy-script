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
TRIGGER_TAG_PREFIX="ci/"
TRIGGER_TAG_SUFIX="$(date +%Y-%m-%dT%H-%M-%S)"
TRIGGER_TAG_SUFIX_REGEX=([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2})
PLATFORM_ANDROID_APK="platform_android_apk"
PLATFORM_ANDROID_AAB="platform_android_aab"
PLATFORM_IOS="platform_ios"