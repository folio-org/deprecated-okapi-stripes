#!/bin/sh

# fail on error
set -e

: ${interactive="yes"}

stripes_repo=$(pwd)/../stripes-experiments

(
cd $stripes_repo
cd stripes-core
npm install
)

if [ "$interactive" = "yes" ]; then
    echo ""
    echo "now start the webpack service with: node stripes-core/webpackServer.js"
fi
#echo "( cd stripes-core && npm run start:webpack )"

