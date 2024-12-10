#################################
#     EXTRACT DATA FROM IPA     #
#################################

function __generate_app_version_from_ipa {
    
    # Get file names
    APP_PATH=$1
    FILE_NAME=$(basename $APP_PATH)

    # Unzip ipa file
    unzip -q $APP_PATH -d .tmp

    # Read info .plist
    INFO_PLIST=.tmp/Payload/**/Info.plist

    APP_VERSION=$(plutil -extract CFBundleShortVersionString xml1 -o - $INFO_PLIST | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')
    BUILD_NUMBER=$(plutil -extract CFBundleVersion xml1 -o - $INFO_PLIST | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')

    # Remove tmp files
    rm -rf .tmp

    echo "$APP_VERSION-$BUILD_NUMBER"
}