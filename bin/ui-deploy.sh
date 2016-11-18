#!/bin/sh
#
# ui-deploy - creates a tenant, some FOLIO UI modules and
#             assign the modules to the tenant
#
# e.g.:
#
# $ tenant=test modules="trivial @folio-sample-modules/trivial-okapi" ./ui-deploy.sh
#

set -e

: ${tenant="test"}
: ${modules="trivial @folio-sample-modules/trivial-okapi https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz"}
: ${is_ui_module=true}

curl='curl -sSf'

module_json=$(mktemp)
tenant_json=$(mktemp)

########################################
# same 1st tenant as manual
#
cat > $tenant_json <<END
{
  "id" : "$tenant",
  "name" : "$tenant library",
  "description" : "$tenant Library"
}
END

if $curl http://localhost:9130/_/proxy/tenants | egrep -q "\"id\" : \"$tenant\",\$"; then
    echo "tenant $tenant already exits, skip creation"
else
    echo "==> Create tenant '$tenant'"
    $curl -w '\n' -X POST -D - \
      -H "Content-type: application/json" \
      -d @$tenant_json \
      http://localhost:9130/_/proxy/tenants
fi


########################################
# modules
#
for module in $modules
do
    case $module in
        @* ) npm="$module"; url="" ;;
        * )  npm=""; url="$module" ;;
    esac
 
    # https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz"
    id=$(echo $module | perl -npe 's,https?://,,i; s/\.tgz$//')
    
    # remove @ and / from id   
    id=$(echo $id | perl -npe 's/^@//; s,/,-,g')
    
    # trivial module
    if $is_ui_module; then
    cat > $module_json <<END
{
  "id" : "$id",
  "name" : "$module",
  "uiDescriptor" : {
     "npm" : "$npm",
     "url" : "$url"
  }
}
END
    else
        cat > $module_json <<END
{
  "id" : "$id",
  "name" : "$module"
}
END
    fi

    if $curl http://localhost:9130/_/proxy/modules | egrep -q "\"id\" : \"$id\",\$"; then
        echo "module $id already exits, skip creation"
    else
        echo ""
        echo "==> Create module '$module'"
        $curl -w '\n' -X POST -D - \
          -H "Content-type: application/json" \
          -d @$module_json  \
          http://localhost:9130/_/proxy/modules
    fi
      
    # Enable tenant
    tenant_enable_json=$(mktemp)
    cat > $tenant_enable_json <<END
{
  "id" : "$id"
}
END

    echo ""
    echo "==> Enable module '$id' for tenant '$tenant'"
    $curl -w '\n' -X POST -D - \
      -H "Content-type: application/json" \
      -d @$tenant_enable_json  \
      http://localhost:9130/_/proxy/tenants/$tenant/modules
  
    # get full info for trivial (repeat for each one returned above)
    $curl -w '\n' -D - http://localhost:9130/_/proxy/modules/$id

done

# get list of enabled modules for tenant
echo ""
echo "==> List modules for tenant '$tenant'"
$curl -w '\n' -D - http://localhost:9130/_/proxy/tenants/$tenant/modules

# show module config
echo ""
for module in $($curl -w '\n' -D - http://localhost:9130/_/proxy/tenants/$tenant/modules |
    egrep '"id"' |awk '{print $3}' | sed -e 's/"//g')
do
    $curl -w '\n'  http://localhost:9130/_/proxy/modules/$module
done

rm -f $module_json $tenant_json $tenant_enable_json
