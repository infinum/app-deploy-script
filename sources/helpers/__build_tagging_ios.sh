#################################
#     EXTRACT DATA FROM IPA     #
#################################

function __generate_app_version_from_ipa {
    
    # Get file names
    APP_PATH="$1"
    CI_BUILD_NUMBER=$2

    # Unzip ipa file
    unzip -q "${APP_PATH}" -d .tmp

    # Read info .plist
    INFO_PLIST=.tmp/Payload/**/Info.plist

    APP_VERSION=$(plutil -extract CFBundleShortVersionString xml1 -o - $INFO_PLIST | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')
    APP_BUILD_NUMBER=$(plutil -extract CFBundleVersion xml1 -o - $INFO_PLIST | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')

    # Remove tmp files
    rm -rf .tmp

    CI_BUILD_SUFFIX=""
    [[ -n "${CI_BUILD_NUMBER}" ]] && CI_BUILD_SUFFIX="b${CI_BUILD_NUMBER}"
    echo "${APP_VERSION}-${APP_BUILD_NUMBER}${CI_BUILD_SUFFIX}"
}