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

echo 
echo "Please wait until main script is installed..."
echo
echo "Fetching script data..."
mkdir .tmp
git clone --quiet git@github.com:infinum/app-deploy-script.git .tmp
echo "Installing..."
cat .tmp/app-deploy.sh > /usr/local/bin/app-deploy
chmod +rx /usr/local/bin/app-deploy
rm -rf .tmp
echo "Installing finished!"
exit 0
