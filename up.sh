#!/bin/bash



 dfx stop
 dfx start --clean --background
 dfx deploy
#   ../

pushd ../Invoice-Apis
nodemon app.js

