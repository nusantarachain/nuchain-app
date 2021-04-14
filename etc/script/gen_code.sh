#!/usr/bin/env bash

echo Re-generate json annotation code...

flutter packages pub run build_runner build $1
pushd sdk
flutter packages pub run build_runner build $1
popd

echo Done.
