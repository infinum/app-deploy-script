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
echo "Press RETURN to continue or any other key to abort"
getc c
if ! [[ "$c" == $'\r' || "$c" == $'\n' ]]; then
exit 1
fi
echo
echo "Fetching script data..."
mkdir .tmp
git clone --quiet git@github.com:infinum/app-deploy-script.git .tmp
echo "Installing..."
cat .tmp/app-deploy.sh > /usr/local/bin/app-deploy
chmod +rx /usr/local/bin/app-deploy
rm -rf .tmp
echo "Done!"
exit 0
