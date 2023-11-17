#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error


 dfx stop
 dfx start --clean --background
 dfx deploy
#   ../

pushd ../Invoice-Apis
nodemon app.js

#node enrollAdmin

#node registerUser

#pm2 restart 3
#node app.js
#popd

#pushd ./explorer
#docker-compose down
#docker volume rm explorer_pgdata
#docker volume rm explorer_walletstore

#popd
