
function __build_tagging {

    __validate_options "$@"

}

function __validate_options {
    shift

    while getopts "e:p:v:" opt; do
        case "$opt" in
            e) ENVIRONMENT="$OPTARG" ;;
            p) APP_PATH="$OPTARG" ;;
            v) BUILD_VERSION="$OPTARG" ;;
            *) echo "Error: Invalid option"; exit 1 ;;
        esac
    done

    # Check if all mandatory options are provided
    if [[ -z "$ENVIRONMENT" || -z "$APP_PATH" || -z "$BUILD_VERSION" ]]; then
        echo "Error: Missing mandatory options."
        echo "Usage: app-deploy tagging -e \"environment_name\" -p \"path/to/app.{ipa/apk}\" -v \"{build number}\""
        echo "Example: app-deploy tagging -e \"internal-staging\" -p \"path/to/app.ipa\" -v \"42\""
        exit 1
    fi
}