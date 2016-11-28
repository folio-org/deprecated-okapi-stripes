#!/bin/sh

# fail on error
set -e

: ${interactive="yes"}

# configure ~/.npmrc to use indexdata npm repo for FOLIO
npm config set @folio:registry https://repository.folio.org/repository/npm-folio/
npm config set @folio-sample-modules:registry https://repository.folio.org/repository/npm-folio/


# okapi-stripes
npm install
#npm install @folio/stripes-core

if [ "$interactive" = "yes" ]; then
    echo ""
    echo "now start the webpack service with: node src/webpackServer.js"
fi

