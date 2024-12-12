################
#     HELP     #
################

function __help { 
        cat << EOF
Usage: app-deploy [OPTION] [ARGUMENTS]

A group of scripts and tools designed to assist in the deployment process. This script can:
  - Initialize deploy options.
  - Create trigger tag for CI/CD.
  - Extract environments from a trigger tag.
  - Generate a final build tag after CI/CD deployment.

Parameters:
  --update                  Update the script to the latest version.
  init                      Initialize the deploy-options file for the project.
  trigger                   Generate a trigger tag for starting the CI/CD flow.
  environments <trigger-tag>
                            Extract environments from the specified trigger tag.
  tagging                   Generate a build tag after CI/CD uploads the build.
                            Accepts the following options:
    -e <environment>        Specify the environment to use as a tag prefix (e.g., internal-staging).
    -p <file-path>          Path to the file from which app version, build number, etc., will be extracted.
                            Supported formats: ipa, apk, aab. 
                            Use in combination with -v for unsupported formats (e.g. zip).
    -b <build-count>        Specify the build count, usually the CI/CD counter.
    -v <custom-app-version> Optional: Override the app version extracted from the file.
                            Useful for unsupported formats.
    -c <changelog>          Optional: Add a changelog to the release tag.

Examples:
  1. Initialize deploy options:
      app-deploy init

  2. Generate a trigger tag:
      app-deploy or app-deploy trigger
      output: ci/internal-staging/2024-12-12T14-32

  3. Extract environments from a trigger tag:
      app-deploy environments ci/internal-staging/2024-12-12T14-32
      output: internal-staging

  4. Generate a final build tag:
      app-deploy tagging -e "internal-staging" -p "path/to/my-app.ipa" -b "123" -c "Added new features"
      output: internal-staging/v1.2.3-44b123

EOF
}