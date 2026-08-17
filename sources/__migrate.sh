#################################
#            MIGRATE            #
#################################

function __migrate_to_homebrew {

    __header_print

    if [ "$APP_DEPLOY_LEGACY_INSTALL" != "true" ]; then
        echo "Already installed via Homebrew - nothing to migrate."
        echo "Use 'brew upgrade app-deploy' to update."
        exit 0
    fi

    if ! command -v brew &> /dev/null; then
        echo "Homebrew is required to migrate."
        echo "Install it from https://brew.sh, then run 'app-deploy --migrate' again."
        exit 1
    fi

    echo "Removing manual installation (requires sudo)..."
    sudo rm -f /usr/local/bin/app-deploy
    sudo rm -rf /usr/local/bin/.app-deploy-sources

    echo
    echo "Installing via Homebrew..."
    brew tap infinum/tap
    brew install app-deploy

    echo
    echo "Migration complete! app-deploy is now managed by Homebrew."
    echo "Use 'brew upgrade app-deploy' to update in the future."
    exit 0
}
