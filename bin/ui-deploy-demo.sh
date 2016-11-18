#!/bin/sh
#
# ui-deploy - creates a tenant, some FOLIO UI modules and
#             assign the modules to the tenant
#
# e.g.:
#
# create two tenants, with ui and non-ui modules
#
# $ tenant="demo" modules_ui="trivial https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz" modules="trivial trivial-okapi" ./ui-deploy-demo.sh
#

set -e

: ${tenant="demo"}
: ${modules_ui="trivial @folio-sample-modules/trivial-okapi"}
: ${modules="https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz"}

program=$(dirname $0)/ui-deploy.sh

tenant=$tenant is_ui_module=true  modules="$modules_ui" $program
tenant=$tenant is_ui_module=false modules="$modules"    $program

