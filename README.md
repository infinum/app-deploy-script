# App Deploy Script

## Description

Deploy script used for creating trigger tags with a tag message in the format `ci/internal-staging/2024-12-16T10-16`, where `internal-staging` is marking the workflow that should be started on the CI. The tag message set from this script can be used later for the changelog message on any CI (e.g., Bitrise). Once the build process is finished on CI/CD and the installation file is uploaded to the deployment service (e.g., TryOut Apps), an additional script is available for creating the final build tag in format `internal-staging/v1.0.0-45b46`, where `internal-staging` is marking the build type (i.e., internal for TryOut Apps, or store for App/Play Store; staging for target/flavor type), `v1.0.0-45` represents the build version (app version, build number, ...), and `b46` that represents the unique build count on CI/CD. Optionally, on some platforms, an additional value `cXX` (e.g., `c100`) can represent the code version.

## Table of contents

* [Requirements](#requirements)
* [Getting started](#getting-started)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)

## Requirements

To successfully push tags to the repo, the local user and/or CI/CD project should have write access to the git repository.

## Getting started

#### Installation

To **install** this script, just run this command in Terminal from your <u>home directory</u>:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/infinum/app-deploy-script/master/install.sh)"
```

This script will install `app-deploy` and all the necessary components in `/usr/local/bin/`. 

Once script is installed, for local trigger tag creation, run `app-deploy init` inside the <u>project root folder</u>. That command will add `.deploy-options.sh` into the project's root folder. Once the file is added, update it according to your project needs.

> Note: Do not change the name or location of the `.deploy-options.sh` file!

#### Update

Script can be updated by running the `--update` command.
```bash
app-deploy --update
```
***This update will not effect `.deploy-options.sh` file.***

> Script commands such as `install`, and `--update` will need `sudo` to execute successfully. Use it when requested.

## Usage
### Script modifications

#### Main option `app-deploy init`

Once `deploy-options` are generated with the `init` command, the script should be used as-is. 

The only part that should be changed is stored inside the `.deploy-options.sh` file under the `deploy_options` function. This part of the script is responsible for creating the first part of the tag that can trigger a specific workflow on CI. If the given values are not enough or do not represent the project structure, they can be replaced with different values. 

> Keep in mind that the prefix `internal-' should be used for builds created for internal testing, while builds for beta testing (e.g., Google Play Beta or Apple TestFlight) or public release should be prefixed as `beta—' or `play store`/ `app store`.

**Final variable name inside the `deploy_options` function must stay: `target`** 

#### Configuration flags

As tag creation is divided into several small steps, some can be skipped and/or disabled by changing configuration flags at the beginning of the script inside the `.deploy-options.sh` file.

```bash
# If enabled, the console will be cleared on every script run.
# By default, this option is enabled
use_automatic_console_clean=true
# If enabled, commits that are not pushed will be pushed automatically without a confirmation dialog.
# By default, this option is disabled
enable_automatic_commit_push=false
# If enabled, a confirmation dialog with a deploy summary will be presented.
# By default, this option is enabled
enable_final_confirmation=true
```
##### Script version
If needed, you can specify the version of the script you want to run by changing the value of the `script_version` parameter. Available options are `v1` for the old (legacy) deployment flow and `v2` for the new deployment flow.
<b>v1</b>
Old deployment flow where local `app-deploy` command will generate a tag that includes and defines the app version and following build number without the `ci/` prefix (e.g.,. `internal-staging/v1.0.0-200`).

<b>v2</b>
This is a new deployment flow in which the local `app-deploy` command generates the new trigger tag described at the beginning of this readme.

### Commands
#### Local trigger `app-deploy [optional trigger]`

Script should be run just by calling the script name from the folder where `.deploy-options.sh` is stored (e.g. root folder):

```bash
app-deploy
```

After that, the script will check if everything is pushed to the remote, and if needed it will push all commits before it continues (automatic push can be enabled with `enable_automatic_commit_push` flag). 

```bash
###############################################################
#                         DEPLOY SCRIPT                       #
#                                                             #
#                   Copyright (c) 2020 Infinum.               #
###############################################################


###############################################################
#                      COMMIT CHECK                           #
###############################################################

---------------------------------------------------------------
Targeting commit: e3e45889b
---------------------------------------------------------------
#123: Add my cool feature
---------------------------------------------------------------
```

The next step is selecting one or multiple targets that should be run on CI. Enter one or more numbers separated by whitespaces:

```bash
###############################################################
#                  DEPLOY TARGET SELECTION                    #
###############################################################

--------------
| TryOutApps |
--------------

[0] Test
[1] Develop
[2] Production

==================

---------
| STORE |
---------

[3] App Store

Enter number in square brackets: 0 1
```

After selecting the target, the script will ask for the changelog. The console will open a preselected text editor where a changelog can be added. Keep in mind that closing that editor without entering the changelog will result in a script termination.

```bash
###############################################################
#                          CHANGELOG                          #
###############################################################

------------------------------------------------------------
Enter changelog message...
------------------------------------------------------------
```

If everything is done correctly, the confirmation step will be shown with the summary of selected options (can be skipped by disabling the `enable_final_confirmation` flag):

```bash
###############################################################
#                          DEPLOY                             #
###############################################################

---------------------------------------------------------------
                      ~ CONFIGURATION ~

Tag: ci/internal-develop/internal-test/2024-12-16T10-26

Changelog:
New features:

* first
* second
---------------------------------------------------------------

Is configuration correct for the CI deployment? [y or enter / n]
```

In the end, the tag is created and pushed to the remote. 

#### Remote CI/CD build tagging `app-deploy tagging`
Once the build is deployed, you can run the `tagging` option that will read the version from the installation file (ipa, apk, aab), combined with some input options, and as output, it will generate deployed build tag (e.g., `internal-staging/v1.0.0-45b46c100`). Mandatory parameters are **e**nvironment `-e`, **p**ath to installation file `p`, and CI/CD **b**uild counter `b`:
```bash
app-deploy tagging -e "internal-staging" -p path/to/app.ipa -b $CI_COUNTER
```
There are two optional parameters: a custom **v**ersion number that overrides one from the installation file `-v` and `-c`, which can be used to set the tag message representing the **c**hangelog.

#### Helper command `app-deploy environments`
To help you with parsing out triggered environments from the trigger tag, you can use `app-deploy environments $TAG` command, where `$TAG` is tag used for triggering the build. Tag must be in the format used by the trigger command (i.e., `ci/env1/env2/timestamp`). 
```bash
deploy environments "ci/env1/env2/timestamp"

output: 
env1
env2
```

For example, this command could be used for mapping trigger env notation into the CI/CD workflow name:
```bash
EXTRACTED_ENVIRONMENTS=$(app-deploy environments "$CI_GIT_TAG" | tr '\n' ' ')

# Process environments
BUILD_ENVIRONMENTS=""
IFS=$' ' read -ra environments <<< "$EXTRACTED_ENVIRONMENTS"

# Map environment from tag to the Workflow name
for environment in "${environments[@]}"; do
    if [[ $environment == 'internal-develop' ]]; then
        BUILD_ENVIRONMENTS+="Development"$'\n'
    elif [[ $environment == 'internal-staging' ]]; then
        BUILD_ENVIRONMENTS+="Staging"$'\n'
    fi
done

# Remove empty line at the end of the list
BUILD_ENVIRONMENTS="$(echo "$BUILD_ENVIRONMENTS")"

# Set $BUILD_ENVIRONMENTS as a global variable on CI/CD that CI can use later as a list of workflows that should be run
```

## Contributing

We believe that the community can help us improve and build better a product.
Please refer to our [contributing guide](CONTRIBUTING.md) to learn about the types of contributions we accept and the process for submitting them.

To ensure that our community remains respectful and professional, we defined a [code of conduct](CODE_OF_CONDUCT.md) <!-- and [coding standards](<link>) --> that we expect all contributors to follow.

We appreciate your interest and look forward to your contributions.

## License

```text
Copyright 2024 Infinum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Credits

Maintained and sponsored by [Infinum](https://infinum.com).

<div align="center">
    <a href='https://infinum.com'>
    <picture>
        <source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
        <img src="https://assets.infinum.com/brand/logo/static/default.svg">
    </picture>
    </a>
</div>
