#################################
#            UPDATE             #
#################################

function __script_auto_update {
    echo 
    echo "Please wait until main script is finished with updating..."
    echo
    echo "Fetching new data..."

    # Create temp folder
    # if [ ! -d ".app_deploy_tmp" ]; then
    #     mkdir .app_deploy_tmp
    # else
    #     rm -rf .app_deploy_tmp
    # fi

    # Get new data
    # git clone --quiet https://github.com/infinum/app-deploy-script.git --branch feature/v2/local-trigger .app_deploy_tmp
    # echo "Updating..."

    # # Move new data to bin / helpers
    # cat .app_deploy_tmp/app-deploy.sh > /usr/local/bin/app-deploy
    # cp -a .app_deploy_tmp/sources/. /usr/local/bin/.app-deploy-sources/

    # LOCAL DEVELOPMENT
    # Comment when not in use
    cat /Users/jaco/Infinum/Infinum_projects/AppDeployScript/app-deploy-script/app-deploy.sh > /usr/local/bin/app-deploy
    cp -a /Users/jaco/Infinum/Infinum_projects/AppDeployScript/app-deploy-script/sources/. /usr/local/bin/.app-deploy-sources/

    # Remove temp folder
    # rm -rf .app_deploy_tmp
    
    echo "Updating finished!"
    exit 0
}
