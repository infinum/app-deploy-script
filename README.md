# App Deploy Script



Deploy script used for creating the tag with tag message in format `internal-all/v1.0.0-1234`, where `internal-all` is marking the workflow that should be started on the CI, `v1.2.3` represents app version and `1234` represents the build number. Tag message set from this script can be used later for the changelog message on any CI (e.g. Bitrise). The build number is number calculated as a total number of tags available on GitHub incremented by one.




## Script modifications

In general, the script should be used as-is. The only part that could be changed is marked as "DEPLOY OPTIONS" and it is available under the `deploy_options` function. This part of the script is responsible for creating the first part of the tag that can trigger a specific workflow on CI. If given values are not enough or they are not representing the project structure, they can be replaced with different values. 
Keep in mind that prefix `internal-` should be used for the builds created for the internal testing, while builds for beta testing (i.e. Google Play Beta or Apple TestFlight) or public release, should be prefixed as `beta-` or `playstore`/ `appstore`.

## Usage

Script should be stored somewhere in the project folder (e.g. in root folder, deployment folder, etc.) and it can be run just by calling the script name:

```bash
./app-deploy.sh
```

After that, the script will check if everything is pushed to the remote and if needed it will push all commits before it continues. 

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

Next step is selecting a target that should be run on CI:

```bash

###############################################################
#                  DEPLOY TARGET SELECTION                    #
###############################################################

--------------
| TryOutApps |
--------------

[0] All
[1] Test
[2] Develop
[3] Simulation
[4] Production

==================

---------------------
| APP STORE CONNECT |
---------------------

[5] App Store

Enter number in square brackets:
```

After selecting the target, the script will check the app version from the latest tag found on the current branch. The new version can be always set by typing it in the console. If the preselected version is the correct one, just hit enter and the script will continue with getting and calculating the next build number.

```bash
###############################################################
#                         APP VERSION                         #
###############################################################

Press enter to use last known version: 2.4.0. (or enter different version)
Getting next build number...

Next app version is: v2.4.0-6029
```

The last step is to add the changelog. When creating the tag, the console will open a preselected text editor where changelog can be added. Keep in mind that closing that editor without entered changelog will result in the script termination.

```bash
###############################################################
#                          CHANGELOG                          #
###############################################################

------------------------------------------------------------
Enter changelog message...
------------------------------------------------------------
```

If everything is done correctly, the confirmation step will be shown with the summary of selected options:

```bash
###############################################################
#                          DEPLOY                             #
###############################################################

---------------------------------------------------------------
                      ~ CONFIGURATION ~

Target: 1. internal-test
Version: v2.4.0-6029
Tag: internal-test/v2.4.0-6029

Changelog:
New features:

* first
* second
---------------------------------------------------------------

Is configuration correct for the CI deployment? [y/n]
```

In the end, the tag is created and pushed to the remote. 

## Contributing

Feedback and code contributions are very much welcome. Just make a pull request with a short description of your changes. By making contributions to this project you permit your code to be used under the same [license](https://github.com/infinum/app-deploy-script/blob/master/LICENSE).

## Credits

Maintained and sponsored by [Infinum](http://www.infinum.com).
<a href='https://infinum.com'>
  <img src='https://infinum.com/infinum.png' href='https://infinum.com' width='264'>
</a>