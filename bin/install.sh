#!/bin/sh

# fail on error
set -e

: ${interactive="yes"}

stripes_repo=$(pwd)/../stripes-experiments

# configure ~/.npmrc to use indexdata npm repo for folio
npm config set @folio:registry https://folio-nexus.indexdata.com/repository/npm-folio/
npm config set @folio-sample-modules:registry https://folio-nexus.indexdata.com/repository/npm-folio/


# okaip-stripes
npm install


# stripes-experiments
(
cd $stripes_repo
cd stripes-core
npm install
)


if [ "$interactive" = "yes" ]; then
    echo ""
    echo "now start the webpack service with: node js/webpackServer.js"
fi
#echo "( cd stripes-core && npm run start:webpack )"

