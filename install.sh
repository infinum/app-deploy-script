#!/usr/bin/env bash

###############################################################
#                       DEPLOY SCRIPT                         #
#                                                             #
#          Script used for creating the specific              #
#        tag used for triggering the CI deployment            #
#                                                             #
#               End tag should look like this:                #
#                  internal-all/v1.0.0-1234                   #
#                                                             #
#                Prepared by Jasmin Abou Aldan                #
#       Copyright (c) 2020 Infinum. All rights reserved.      #
###############################################################

bold=$(tput bold)
normal=$(tput sgr0)

echo "==> ${bold}This script will install:${normal}"
echo "/usr/local/bin/app-deploy"
echo
if [[ $1 =~ "--silent" ]]; then
    read -r -p "Do you want to proceed? [y/n] " c
    if ! [[ ${c} =~ ^(yes|y|Y) ]] || [ -z ${c} ]; then
        exit 1
    fi
fi

echo
echo "Fetching script data..."

# Create temp folder
if [ ! -d ".app_deploy_tmp" ]; then
    mkdir .app_deploy_tmp
else
    rm -rf .app_deploy_tmp
fi

# Get install files
git clone --quiet https://github.com/infinum/app-deploy-script.git --branch feature/v2/local-trigger .app_deploy_tmp
echo "Installing..."

# Move main script to bin folder
cat .app_deploy_tmp/app-deploy.sh > /usr/local/bin/app-deploy

# Move helpers to helpers folder inside bin
if [ ! -d "/usr/local/bin/.app-deploy-sources" ]; then
    mkdir /usr/local/bin/.app-deploy-sources/
fi
cp -a .app_deploy_tmp/sources/. /usr/local/bin/.app-deploy-sources/

# Add permission to read files
chmod +rx /usr/local/bin/app-deploy
chmod +rx /usr/local/bin/.app-deploy-sources/

# Remove temp install folder
rm -rf .app_deploy_tmp

echo "Done!"
exit 0
