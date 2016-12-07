# okapi-stripes

Copyright (C) 2016 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

## Introduction

Okapi integrated service that generates static UI assets (JS/HTML/CSS) from Stripes modules and metadata.

## Local installation

First, checkout the ```okapi-stripes``` repo from GitHub:

```
$ git clone ssh://git@github.com/folio-org/okapi-stripes
```

Note: Node.js version 6.x is required for running stripes-experiments. Older Node.js 
versions are likely to fail due to changes in react/redux

Please use npm version 3.x or higher. The older npm 2.x is much slower and downloads
many more files.

### macOS

```
$ brew install node
```

### Debian

Go to https://nodejs.org/en/download/current/ and download the Linux Binaries. Extract the
archive, and symlink the programs "node" and "npm" to /usr/local/bin

### MS Windows

Go to https://nodejs.org/en/, select version 6.x for your Windows version and follow 
the instructions in the installer. (Tested for Node.js 6.2.2, 64bit version, on Windows 7.)  

## For AWS S3

To upload files to AWS S3, you need the aws(1) tool installed, and setup `~/.aws`
for you. See `aws configure`

### Debian

```
$ sudo apt-get install awscli
```

### macOS

```
$ brew install awscli
```

## Webpack service

Run a local installation (see the readme above) in ./okapi-stripes

```
$ ./bin/install.sh
```

Start webpack service on port 3030:

```
$ node src/webpackServer.js 
```

Open web form to generate folio UI bundle:

```
open http://localhost:3030
```

then fill out the forms, and press submit.

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

In your browser:

```
open http://localhost:3030
```

and after 20-30 seconds you should get the result as:

```
{"status":201,"url":"http://s3.amazonaws.com/folio-ui-bundle/tenant/test-1469456474/index.html"}
```

## Example run with POST (command line)

Or more Okapi-style with a post request:

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

Testing on the command line:

```
$ env tenant="test" ui_url="trivial https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz" ./bin/tenant-bundle.sh
```

## Misc

AWS S3 supports both HTTP and HTTPS. We are using HTTP URLs to enable
access to a local running okapi instance on localhost:9130

## uiDescriptor

Note: to run the following examples, an okapi service must be running
on the same machine: ```cd okapi; mvn install; mvn exec:exec'''

Create a tenant "test", and assign 2 UI modules:

```
$ tenant=test module="trivial trivial-okapi" ./bin/ui-deploy.sh
```

Create a tenant "demo", assign 2 modules and 2 UI modules:

```
$ tenant="demo" modules_ui="patrons https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz" modules="trivial trivial-okapi" ./ui-deploy-demo.sh
```

Create a bundle for UI modules for tenant "demo":

```
$ node src/uiDescriptor.js demo 
found ui module: https://s3.amazonaws.com/folio-ui-bundle/tarball/trivial-wolfram.tgz
found ui module: patrons
```

## Troubleshooting

To cleanup local npm modules, run:

```
$ ./bin/clean.sh
```

## Additional information

See [stripes-experiments](https://github.com/folio-org/stripes-experiments).

Other FOLIO Developer documentation is at [dev.folio.org](http://dev.folio.org/)


--
Index Data, Nov 2016

