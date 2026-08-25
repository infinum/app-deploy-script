#!/usr/bin/env bash

# Resolve the real location of this script, following symlinks. Homebrew invokes
# the script through an exec wrapper with an absolute path, but npm installs a
# plain symlink (e.g. /usr/local/bin/app-deploy -> ../lib/node_modules/...),
# so BASH_SOURCE alone would point at the wrong directory.
APP_DEPLOY_SELF="${BASH_SOURCE[0]}"
while [ -L "$APP_DEPLOY_SELF" ]; do
    APP_DEPLOY_SELF_DIR="$(cd "$(dirname "$APP_DEPLOY_SELF")" && pwd)"
    APP_DEPLOY_SELF="$(readlink "$APP_DEPLOY_SELF")"
    [[ "$APP_DEPLOY_SELF" != /* ]] && APP_DEPLOY_SELF="$APP_DEPLOY_SELF_DIR/$APP_DEPLOY_SELF"
done
APP_DEPLOY_ROOT="$(cd "$(dirname "$APP_DEPLOY_SELF")" && pwd)"

if [ -d "$APP_DEPLOY_ROOT/sources" ]; then
    APP_DEPLOY_SOURCES="$APP_DEPLOY_ROOT/sources"
    APP_DEPLOY_LEGACY_INSTALL="false"
elif [ -d "$APP_DEPLOY_ROOT/.app-deploy-sources" ]; then
    APP_DEPLOY_SOURCES="$APP_DEPLOY_ROOT/.app-deploy-sources"
    APP_DEPLOY_LEGACY_INSTALL="true"
else
    echo "Unable to locate app-deploy source files."
    echo "Please reinstall via 'brew install infinum/tap/app-deploy' or 'npm install -g @infinum/app-deploy'."
    exit 1
fi

# Which package manager owns this installation. Only affects user-facing hints
# (update instructions etc.) - the script itself never depends on either.
if [[ "$APP_DEPLOY_ROOT" == */node_modules/* ]]; then
    APP_DEPLOY_PACKAGE_MANAGER="npm"
else
    APP_DEPLOY_PACKAGE_MANAGER="brew"
fi

source "$APP_DEPLOY_SOURCES/__constants.sh"
source "$APP_DEPLOY_SOURCES/__help.sh"

if [ -z "$1" ] || [ "$1" == 'trigger' ] ; then
    source ./.deploy-options.sh
    source "$APP_DEPLOY_SOURCES/__trigger_deploy.sh"
fi
source "$APP_DEPLOY_SOURCES/__migrate.sh"
source "$APP_DEPLOY_SOURCES/__init.sh"
source "$APP_DEPLOY_SOURCES/__env_extractor.sh"
source "$APP_DEPLOY_SOURCES/__build_tagging.sh"

###############################################################
#                       DEPLOY SCRIPT                         #
#                                                             #
#          Script used for creating the specific              #
#        tag used for triggering the CI deployment            #
#                                                             #
#                                                             #
#                Prepared by Jasmin Abou Aldan                #
#       Copyright (c) 2024 Infinum. All rights reserved.      #
###############################################################

# Use global variables at your own risk as this can be overridden in the future.
set -e

VERSION="2.2.0"

#################################
#       START EVERYTHING        #
#################################

if [ "$1" != '-h' ] && [ "$1" != '--help' ] && [ "$1" != '-v' ] && [ "$1" != '--version' ] && [ "$1" != '--migrate' ] && [ "$APP_DEPLOY_LEGACY_INSTALL" == "true" ]; then
    __legacy_install_warning
fi

if [ "$1" == '-h' ] || [ "$1" == '--help' ] ; then
    __help
elif [ "$1" == '-v' ] || [ "$1" == '--version' ] ; then
    echo "app-deploy $VERSION"
elif [ "$1" == '--update' ] ; then
    __update_removed_notice
elif [ "$1" == '--migrate' ] ; then
    __clear_console
    __migrate_to_homebrew
elif [ "$1" == 'init' ] ; then
    __clear_console
    __init
elif [ -z "$1" ] || [ "$1" == 'trigger' ] ; then # Empty input or "trigger"
    __clear_console
    __trigger_deploy "$@"
elif [ "$1" == 'environments' ] ; then
    __env_extractor "$2"
elif [ "$1" == 'tagging' ]; then
    __build_tagging "$@"
else
    echo
    echo "Unsuported command!"
    echo
    exit 29
fi
