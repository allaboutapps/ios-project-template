################
# iOS Makefile #
################

######## START CONFIG ########

# Adjust these config parameters according to your project:

# 1) The name of the Xcode Project file
XCODEPROJ = Example.xcodeproj

# 2) The scheme for building and testing the app
SCHEME = Example

# 3) The configuration to build and run tests
CONFIGURATION = Debug

# 4) The location of the Info.plist file
APP_PLIST = MyProject/SupportingFiles/Info.plist

# (optional)

# Device
DEVICE_HOST = platform='iOS Simulator',OS='9.0',name='iPhone 6'

# SDK (build only)
BUILD_SDK = iphonesimulator

# Codesigning (archive only)
DEVELOPER_NAME = iPhone Developer: Christian Kaar (L2QDLEBB7A)
PROVISONING_PROFILE = aaa_Wildcard_Dev.mobileprovision

# Push notifications
PUSH_DEVICE_TOKEN = 12345
PUSH_CERTIFICATE_PEM = path/to/push_certificate.pem

######## END CONFIG ########


#Build/Log files and directories
BUILD_DIR = build
LOG_DIR = $(BUILD_DIR)/logs
LOG_FILE_BUILD = $(LOG_DIR)/xcode_build_raw.log
LOG_FILE_TEST = $(LOG_DIR)/xcode_test_raw.log

#Constants
VERSION_STRING = $(shell ${PLIST_BUDDY} -c "Print CFBundleShortVersionString" ${APP_PLIST})
DATE_FULL = $(shell date "+%Y.%m.%d-%H.%M.%S")
FINAL_BUILD_DIR = $(BUILD_DIR)/xcodebuild/Build/Products/$(CONFIGURATION)-$(BUILD_SDK)
PLIST_BUDDY = /usr/libexec/PlistBuddy

#Fancy colors
NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m


#################
# MAKE COMMANDS #
#################

# List commands that have the same name as e.g. files, directories or other CLI commands
.PHONY: build clean

all: check_dirs_and_files clean lint test build archive

gitinit:
	rm dir_tree.png
	rm -rf .git
	git init

setup: gitinit
	gem install xcpretty
	gem install houston
	brew install swiftlint

######## FILE & DIR CHEKS ########

check_dirs_and_files: check_build_dir check_log_dir check_build_logs check_test_logs
check_dirs_and_files:
	@if [ $$? -eq 0 ]; then echo "$(OK_COLOR)created build and log directories (if they don't exist)$(NO_COLOR)"; else echo "$(ERROR_COLOR)failure while creating log directories $(NO_COLOR)"; fi;

check_build_dir:
	@test -d $(BUILD_DIR) || mkdir $(BUILD_DIR)

check_log_dir:
	@test -d $(LOG_DIR) || mkdir $(LOG_DIR)

check_build_logs:
	@test -r $(LOG_FILE_BUILD) || touch $(LOG_FILE_BUILD)

check_test_logs:
	@test -r $(LOG_FILE_TEST) || touch $(LOG_FILE_TEST)

######## XCODEBUILD ########

clean:
	xcodebuild -project $(XCODEPROJ) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' clean | xcpretty -c

test: check_dirs_and_files
	set -o pipefail && xcodebuild -project $(XCODEPROJ) -scheme $(SCHEME) -configuration $(CONFIGURATION) -sdk iphonesimulator -destination $(DEVICE_HOST) build test | tee $(LOG_DIR)/xcode_test_raw.log  | xcpretty -c --report html --output "$(BUILD_DIR)/testreports/$(VERSION_STRING)/$(DATE_FULL)-results.html"

build: check_dirs_and_files
	set -o pipefail && xcodebuild -project $(XCODEPROJ) -scheme $(SCHEME) -configuration $(CONFIGURATION) -sdk $(BUILD_SDK) -destination $(DEVICE_HOST) -derivedDataPath $(BUILD_DIR)/xcodebuild build | tee $(LOG_DIR)/xcode_build_raw.log | xcpretty -c
	@open $(FINAL_BUILD_DIR)

archive: build
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${FINAL_BUILD_DIR}/${SCHEME}.app" -o "${PWD}/${FINAL_BUILD_DIR}/${SCHEME}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISONING_PROFILE}"

lint:
	swiftlint lint

push: 
	apn push $(PUSH_DEVICE_TOKEN) -c $(PUSH_CERTIFICATE_PEM) -m "Test"
