source /usr/local/bin/.app-deploy-sources/__constants.sh

#################################
#            UPDATE             #
#################################

function __script_auto_update {

    __header_print
    echo 
    echo "Please wait until main script is finished with updating..."
    echo
    echo "Fetching new data..."

    # Create temp folder
    if [ ! -d ".app_deploy_tmp" ]; then
        mkdir .app_deploy_tmp
    else
        trap "rm -rf .app_deploy_tmp" EXIT
    fi

    # Get new data
    git clone --quiet https://github.com/infinum/app-deploy-script.git .app_deploy_tmp
    echo "Updating..."

    # Move new data to bin / helpers
    cat .app_deploy_tmp/app-deploy.sh > /usr/local/bin/app-deploy
    cp -a .app_deploy_tmp/sources/. /usr/local/bin/.app-deploy-sources/

    # Remove temp folder
    trap "rm -rf .app_deploy_tmp" EXIT
    
    echo "Updated to $VERSION!"
    exit 0
}
