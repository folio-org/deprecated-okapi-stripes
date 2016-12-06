#!/bin/bash

set -e
pwd=$(pwd)
#pwd_se="$(pwd)/../stripes-core"
pwd_se="$(pwd)"

#github_url="ssh://git@github.com/folio-org/stripes-experiments"
: ${github_url="$pwd_se"} 

: ${aws_s3_path="folio-ui-bundle/tenant"}
aws_url="http://s3.amazonaws.com/$aws_s3_path"

#: ${ui_url="https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz"}
: ${ui_url="@folio-sample-modules/trivial"}
: ${stripes_branch=""}
: ${stripes_tenant="carl"}
: ${stripes_debug=false}
: ${stripes_awscli=true}


echo "node version: $(node --version)"
echo "npm  version: $(npm --version)"

#tmp=/tmp
#if [ -n "$TMPDIR" ]; then
#    tmp=$TMPDIR
#fi
#dir=$(mktemp -d $tmp/stripe.XXXXXXXX)
#
#cd $dir
#pwd 
#if [[ $(uname -s) =~ CYGWIN.* ]]; then
#    github_url="${github_url/\//\\}"
#fi
#git clone -q "$github_url"
#cd $(basename "$github_url")

if [ -n "$stripes_branch" ]; then
    if ! git branch | egrep -q $stripes_branch; then
        git checkout -b $stripes_branch origin/$stripes_branch
    fi
fi

if ! echo $stripes_tenant | egrep -q -i '^[a-z0-9_-]+$'; then
    echo "illegal tenant name: [A-Za-z0-9_-]: $tenant"
    exit 1
fi

time=$(date '+%s')
bundle_dir="$stripes_tenant-$time"

#(
#pwd
#cd ../stripes-core
#rm -rf $bundle_dir
mkdir $bundle_dir
##cp favicon.ico  $bundle_dir
#)

mkdir -p dev

#( cd dev $pwd/bin/modules.sh $ui_url ) > webpack.config.tenant.js
$pwd/bin/modules.sh $ui_url  > stripes.config.js 

# GNU tar needs special options
if tar --help| egrep -w -- --wildcards >/dev/null; then
    tar_opt=--wildcards
fi

############################
# main
#
# add new UI module to bundle
for url in $ui_url
do 
    # a directory, just copy
    if [ -d "$url" ]; then
        if echo $url | egrep -q -i '^[a-z0-9_-]+$'; then
            rsync -a $url dev
            ( cd $(basename $url) && pwd && npm install )
        else
            echo "illegal directory path: [A-Za-z0-9_-]: $url"
            exit 1
        fi

    # fetch from web site
    else
        if echo $url | egrep -q -i '^https?://[a-z0-9]+\S+$'; then
            ( cd dev
            wget -q $url
            tar $tar_opt -xzf $(basename $url) '[a-zA-Z0-9]*'
            (cd $(basename $url .tgz) && npm install )
            )
        else
            if echo $url | egrep -q -i '^@folio-'; then
                :
            else
                echo "illegal URL: $url"
                exit 1
            fi
        fi
    fi
done

## re-use installed node_modules
#if [ -d "$pwd_se/stripes-core/node_modules" ]; then
#    rsync -a "$pwd_se/stripes-core/node_modules" stripes-core
#fi
#
#cd stripes-core
#cp $pwd/src/webpack.config.cli.tenant.js .

npm install
npm run build:tenant

cp index.html $bundle_dir
rsync -a static $bundle_dir

if ! $stripes_awscli; then
    echo "No AWS S3 upload, see $(pwd)/$bundle_dir/index.html"
    exit
else 
    if aws s3 sync --quiet $bundle_dir s3://$aws_s3_path/$bundle_dir; then
        echo $aws_url/$bundle_dir/index.html
    else
    	echo "Upload to $aws_url failed, please check your ~/.aws setup"
    	exit 1
    fi
fi

# cleanup temp space
if $stripes_debug; then
    pwd
else
    rm -rf $dir &
fi

