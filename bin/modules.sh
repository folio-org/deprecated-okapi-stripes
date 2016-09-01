#!/bin/sh

pwd=$(pwd)
data=""
for module in $@
do
    m=$pwd/$(basename $module ".tgz")
    if [ -z "$data" ]; then
	data="'$m': {}"
    else
	data=$(printf "$data,\n\t%s" "'$m': {}")
    fi
done


cat <<EOF;

// Base Webpack configuration for building Stripes at the command line,
// including Stripes configuration.

const path = require('path');
const webpack = require('webpack');

module.exports = {
  output: {
    path: path.join(__dirname, 'static'),
    filename: 'bundle.js',
    publicPath: 'static/'
  },
  stripesLoader: {
    okapi: { 'url':'http://localhost:9130' },
    modules: {
	$data
    }
  }
};

EOF

