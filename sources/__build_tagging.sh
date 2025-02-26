source /usr/local/bin/.app-deploy-sources/__constants.sh
source /usr/local/bin/.app-deploy-sources/helpers/__build_tagging_ios.sh
source /usr/local/bin/.app-deploy-sources/helpers/__build_tagging_android.sh

#################################
#        CREATE BUILD TAG       #
#################################

# Main logic

function __build_tagging {

    __validate_options "$@"

    # There is no custom app version, try to extract from passed installation file
    if [[ -z "$CUSTOM_APP_VERSION" ]]; then
        APP_VERSION=""
        APP_PLATFORM=$(__check_platform)
        if [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_APK" ]; then
            APP_VERSION=$(__generate_app_version_from_apk "$APP_PATH" "$BUILD_COUNT")
        elif [ "$APP_PLATFORM" == "$PLATFORM_ANDROID_AAB" ]; then
            APP_VERSION=$(__generate_app_version_from_aab "$APP_PATH" "$BUILD_COUNT")
        elif [ "$APP_PLATFORM" == "$PLATFORM_IOS" ]; then
            APP_VERSION=$(__generate_app_version_from_ipa "$APP_PATH" "$BUILD_COUNT")
        elif [[ ! -n "$CUSTOM_APP_VERSION" ]]; then
            echo
            echo "Unsupported file format: ${APP_PATH##*.}"
            echo "If unsupported file format is used (i.e., none of apk, aab, or ipa),"
            echo "you have to define the custom app version (option -v)."
            echo
            exit 1
        fi
    fi

    __create_and_push_tag
}

# Tag creation & push

function __create_and_push_tag {
    
    CALCULATED_APP_VERSION=""
    # If there is a custom app version passed, append build number to it
    if [[ -n "$CUSTOM_APP_VERSION" ]]; then
        SUFFIX=""
        [[ -n "${BUILD_COUNT}" ]] && SUFFIX="b${BUILD_COUNT}"
        CALCULATED_APP_VERSION="${CUSTOM_APP_VERSION}${SUFFIX}"
    fi

    CHANGELOG=${CHANGELOG:-""} # Set empty string if changelog is not available
    TAG="${ENVIRONMENT}/v${CALCULATED_APP_VERSION:-$APP_VERSION}"
    git tag -a "$TAG" -m "${CHANGELOG}"
    git push origin "$TAG"
}

# Validation and checks

function __validate_options {
    shift

    while getopts "e:p:b:v:c:" opt; do
        case "$opt" in
            e) ENVIRONMENT="$OPTARG" ;;
            p) APP_PATH="$OPTARG" ;;
            b) BUILD_COUNT="$OPTARG" ;;
            v) CUSTOM_APP_VERSION="$OPTARG" ;;
            c) CHANGELOG="$OPTARG" ;;
            *) echo "Error: Invalid option"; exit 1 ;;
        esac
    done

    # Check if mandatory options are provided
    if [[ -z "$ENVIRONMENT" ]]; then
        echo "Error: Missing mandatory option -e (environment)."
        echo "Usage: app-deploy tagging -e \"environment_name\" [-p \"path/to/app.{ipa/apk}\" | -v \"version\"] -b \"{build count}\""
        echo "Example: app-deploy tagging -e \"internal-staging\" -p \"path/to/app.ipa\" -b \"42\""
        exit 1
    fi

    # Ensure only one of -p or -v is set, and at least one is provided
    if [[ -n "$APP_PATH" && -n "$CUSTOM_APP_VERSION" ]]; then
        echo "Error: Options -p (path) and -v (version) are mutually exclusive. Provide only one."
        echo "Usage: app-deploy tagging -e \"environment_name\" [-p \"path/to/app.{ipa/apk}\" | -v \"version\"] -b \"{build count}\""
        exit 1
    elif [[ -z "$APP_PATH" && -z "$CUSTOM_APP_VERSION" ]]; then
        echo "Error: Either -p (path) or -v (version) must be provided."
        echo "Usage: app-deploy tagging -e \"environment_name\" [-p \"path/to/app.{ipa/apk}\" | -v \"version\"] -b \"{build count}\""
        exit 1
    fi

    # Ensure BUILD_COUNT is set (even if empty string is allowed)
    # Used older syntax (instead of [[ ! -v BUILD_COUNT ]]) as this -v was introduced in bash v4, while macOS comes with preinstalled v3
    if ! declare -p BUILD_COUNT &>/dev/null; then
        echo "Error: Missing mandatory option -b (build count)."
        echo "Usage: app-deploy tagging -e \"environment_name\" [-p \"path/to/app.{ipa/apk}\" | -v \"version\"] -b \"{build count}\""
        exit 1
    fi
}

function __check_platform {
    if [ ${APP_PATH##*.} == "ipa" ]; then
        echo $PLATFORM_IOS
    elif [ ${APP_PATH##*.} == "apk" ]; then
        echo $PLATFORM_ANDROID_APK
    elif [ ${APP_PATH##*.} == "aab" ]; then
        echo $PLATFORM_ANDROID_AAB
    fi
}