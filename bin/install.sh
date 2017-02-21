#!/bin/sh

# fail on error
set -e

: ${interactive="yes"}

# configure ~/.npmrc to use indexdata npm repo for FOLIO
yarn config set @folio:registry https://repository.folio.org/repository/npm-folio/
yarn config set @folio-sample-modules:registry https://repository.folio.org/repository/npm-folio/


# okapi-stripes
yarn install

if [ ! -e src ]; then
    ln -s ./node_modules/@folio/stripes-core/src
fi

if [ "$interactive" = "yes" ]; then
    echo ""
    echo "now start the webpack service with: node ./bin/webpackServer.js"
fi

