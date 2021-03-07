#!/usr/bin/env bash


pushd sdk/js_api && yarn build
popd
pushd sdk/js_as_extension && yarn build
popd

