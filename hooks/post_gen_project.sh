#! /bin/bash

xcodegen
carthage update --platform ios --cache-build

printf 'all done - enjoy \U1F680\n'