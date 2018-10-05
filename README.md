# iOS Project Template 📱

## Setup

1. Open Xcode -> Create a new Xcode Project
	* Name: `<MyExampleProject>`
	* Choose the "Single View Template"
		* ✔ Include Unit Tests
		* ✔ Include UI Tests
	* Navigate into the `<my-example-project>` folder
	* Click **Create**
	* Close Xcode
1. In your project root directory, create a folder structure that matches the folders in the `Example` folder and copy the `Example/Code` folder to your project. It contains some helpers to get you started.
1. Move all existing project files into their respective folder (i.e. `Info.plist` into `SupportingFiles` and `ViewController.swift` into `ViewControllers`)

## Bend Xcode to your will

1. Open the `<MyExampleProject>.xcodeproj` file
2. Remove all red entries under \<MyExampleProject>
3. Drag all directories under \<MyExampleProject> from Finder to Xcode under <MyExampleProject>
	* [✔] Copy Items if needed
	* [✔] Create groups
4. Remove references to `.gitkeep` Files (in Xcode) in every sub-directory of \<MyExampleProject> that already contains a file
5. Naviagte to the \<MyExampleProject> Target and click "Choose Info.plist File..." (at the top)
	* Choose `<MyExampleProject>/SuportingFiles/Info.plist`
6. In the App Icons section click "Use Asset Catalog" for App Icons Source
	* Use `Assets` Catalog
	* Don't migrate Launch Image
7. Choose AppIcon instead of AppIcon-2 from drop down
8. Navigate to Assets Catalog and remove AppIcon-2 (Xcode... 😫)

## Further setup
* Run `carthage update --platform ios` to install/update all needed dependencies
* Run `make gitinit` to setup a new git repo in the project root folder (**WARNING:** removes any existing git repo in the project root folder)
* Update the `.swiftlint.yml` file to include the project root folder 
* Fill the README
* Delete this TODO section. (And enjoy your fresh and clean Project-setup 🙌)

--------


# Project Title

---

⚡️ Swift: x.x 📱 iOS x.x 🌎 [API Docs](http://linktoswaggerdocs)

---

Project description in 1-5 sentences.

[Screenshots]

## Structure

TODO

## Documentation

Where do I find API docs, wireframes, etc.?

## Bitrise

Is Bitrise CI setup?