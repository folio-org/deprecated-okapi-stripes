# okapi-stripes

Copyright (C) 2016 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Installation

$ git clone ssh://git@github.com/folio-org/okapi-stripes
$ git clone ssh://git@github.com/folio-org/stripes-experiments

Note: node.js version 6.x is required for running stripes-experiments. Older node.js 
versions are likely to fail due changes in react/redux

### macos
```
$ brew install node
```

### debian
go to https://nodejs.org/en/download/current/ and download the Linux Binaries. Extract the
archive, and symlink the programs "node" and "npm" to /usr/local/bin

### MS Windows
Go to https://nodejs.org/en/, select version 6.x to for your Windows version and follow 
the instructions in the installer. (Tested for Nodejs 6.2.2, 64bit version, on Windows 7.)  

## AWS S3

To upload files to AWS S3, you need the aws(1) tool installed, and setup ~/.aws
for you. See `aws configure'

### debian
$ sudo apt-get install awscli

### macos
$ brew install awscli


## Webpack service

run a local installation (see the readme above) in ./okapi-stripes
```
$ ./bin/install.sh
```

start webpack service on port 3030
```
$ node src/webpackServer.js 
```

open web form to generate folio UI bundle
```
open http://localhost:3030
```
and fill out the forms, and press submit


## Example run with GET (browser)

```
$ node src/webpackServer.js
```

```
Example app listening on http://localhost:3030
Run shell command: env stripes_tenant="test" ui_url="trivial https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz  " ./bin/tenant-bundle.sh
Run build, may take 20-30 seconds, tenant test
UI module: ["trivial","https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz","",""]
Webpack script is done
AWS S3 URL: http://s3.amazonaws.com/folio-ui-bundle/tenant/test-1469456474/index.html
```


in your browser
```
open http://localhost:3030
```

and after 20-30 seconds you should get the result as:
```
{"status":201,"url":"http://s3.amazonaws.com/folio-ui-bundle/tenant/test-1469456474/index.html"}
```


## Example run with POST (command line)

or more Okapi style with a post request:

```
$ cat etc/post.json
{"url":["trivial", "https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-okapi.tgz"] }
```
    
```
$ curl -v -H "X-Okapi-Tenant-Id: test2" -X POST --data-binary @./etc/post.json -H "Content-Type: application/json" 'http://localhost:3030/bundle'
HTTP/1.1 201 Created
Location: http://s3.amazonaws.com/folio-ui-bundle/tenant/test2-1469549040/index.html
```


## Testing with a shell script

testing on the command line
```
$ env tenant="test" ui_url="trivial https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz" ./bin/tenant-bundle.sh
```


## Misc

AWS S3 supports both HTTP and HTTPS. We are using HTTP URLs to enable
access to a local running okapi instance on localhost:9130

## uiDescriptor

Create a tenant "test", and assign 2 UI modules:

```
$ tenant=test module="trivial trivial-okapi" ./bin/ui-deploy.sh
```

Create a tenant "demo", assign 2 modules and 2 UI modules

```
$ tenant="demo" modules_ui="patrons https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz" modules="trivial trivial-okapi" ./ui-deploy-demo.sh
```


Create a bundle for UI modules for tenant "demo"
```
$ node src/uiDescriptor.js demo 
found ui module: https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz
found ui module: patrons
```

--
Index Data, Aug 2016

