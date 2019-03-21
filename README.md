# iOS Project Template 📱
Project template for our iOS apps

## Setup

1. Run `cookiecutter --checkout gh-automatic-configuration https://github.com/allaboutapps/ios-project-template.git`. You'll be asked for project name, team details and bundle identifier details. `cookiecutter` will create all files needed from the template on `github`.
2. Change directory to the project directory. Run `xcodegen` there. This will create the `Xcode` project file.

## Further setup
* Run `carthage update --platform ios --no-use-binaries --cache-build` to install/update all needed dependencies
* Build and run the project.
