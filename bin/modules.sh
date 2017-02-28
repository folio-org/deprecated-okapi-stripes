#!/bin/sh

pwd=$(pwd)
data=""
for module in $@
do
    case $module in
        @* ) m="$module" ;;
        *  ) m=$pwd/$(basename $module ".tgz") ;;
    esac
        
    if [ -z "$data" ]; then
	data="'$m': {}"
    else
        data=$(printf "$data,\n\t%s" "'$m': {}")
    fi
done


cat <<EOF;

module.exports = {
  okapi: { 'url':'http://localhost:9130', 'tenant':'test' },
  config: { reduxLog: true, disableAuth: true },
  modules: {
	$data
  }
};

EOF

