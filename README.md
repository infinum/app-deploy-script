# App Deploy Script

A group of scripts facilitates mobile app deployment over CI with the following features:
- Initialize deploy options
- Extract environments from a trigger tag
- Creating trigger tags for starting a specific deployment workflow on the CI
- Creating final build tags by extracting environment and version data from the trigger tag and the resulting binary. 

Trigger tags use the following format: `ci/internal-staging/2024-12-16T10-16`, where `internal-staging` should match the trigger condition for starting the appropriate workflow on the CI. The tag message set from this script can be used later for the changelog message on any CI (e.g., Bitrise). 

Once the build process is finished on CI/CD and the installation file is uploaded to the deployment service, an additional script is available for creating the final build tag in format `internal-staging/v1.0.0-45b46`, where `internal-staging` is marking the build type (i.e., internal for TryOut Apps, or store for App/Play Store; staging for target/flavor type), `v1.0.0-45` represents the build version (app version, build number, ...), and `b46` that represents the unique build count on CI/CD. Optionally, an additional value, `cXX` (e.g., `c100`), can represent the code version on some platforms.

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

For more details on migrating from v1 to v2, please check the [Migration from v1 to v2](https://github.com/infinum/app-deploy-script/wiki/Migration-from-v1-to-v2) guidelines.

## Usage

For detailed usage documentation, please check the [wiki pages](https://github.com/infinum/app-deploy-script/wiki).

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
