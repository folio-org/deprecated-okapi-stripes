#!/usr/bin/env node

var express = require('express');
var app = express();
var port = 3030;
var bodyParser = require('body-parser')

var request = require('request');

app.use(bodyParser.urlencoded({ extended: false }))

// curl -H "Content-Type: application/json" 
app.use(bodyParser.json());

const path = require('path')

var exec = require('child_process').exec;

var cache = {};
var error = {}; // global error object
var debug = 2;

app.get('/', function (req, res) {
  // res.send("Please use http://localhost:" + port + "/bundle?tenant=tenant&url=module1&url=module2 ...\n");
  res.sendFile( path.resolve('./www/webpack.html'))
});

app.get('/readme.html', function (req, res) {
    var fs = require('fs');
    // var markdown = require( "markdown" ).markdown;
    var markdown = require( "markdown-it" )()
      .set({ html: true, breaks: true })
    
    var readme = fs.readFileSync(path.resolve('./README.md'), { encoding: 'utf8' });
    
    res.contentType("text/html");
    res.send( markdown.render(readme));
});

app.get('/readme.md', function (req, res) {
  res.contentType("text/plain");
  res.sendFile( path.resolve('./README.md'))
});

app.get('/favicon.ico', function (req, res) {
  res.contentType("image/png");
  res.sendFile( path.resolve('./www/favicon.ico'))
});


app.get('/bundle', function (req, res) {
  myapp('get', req, res);
});
app.post('/bundle', function (req, res) {
  myapp('post', req, res);
});

// remove empty entries from list
function cleanup_list(list) {
  var _list = [];
  
  for(var i = 0; i < list.length; i++) {
    if (list[i] != "") {
      _list.push(list[i]);
    }
  }
  return _list;
}

function myapp (type, req, res) {
  var method = type == 'get' ? 'query' : 'body';

  // GET requests read the tenant from an URL parameter, okapi POST requests from HTTP header  
  var tenant = type == 'get' ? req[method].tenant : req.get('X-Okapi-Tenant-Id');
  
  if (typeof tenant == 'undefined' || tenant == '') {
    return res.send(JSON.stringify({status: 503, message: 'missing tenant parameter' }));
  }
  if (!tenant.match(/^[[\w\-]+$/)) {
    return res.send(JSON.stringify({status: 503, message: 'wrong tenant parameter [A-Za-z0-9-]+' }));
  }

  //var id = [];
  //id.push(tenant);
  //id.push(req.query.url);
  //var id_tag = id.join("|");
  //const res_data = JSON.parse(req.body);
  //console.log(req.body);
  
  var ui_url;
  if (typeof req[method].module_type == 'string' && req[method].module_type != '') {
    
    var module_type = req[method].module_type;
    if (module_type == 'ui') {
        // we do not have the URLs yet. 
        return ui_module(tenant, res);
    } else{
      return res.send(JSON.stringify({status: 503, message: 'unknown module_type: ' + module_type }));
    }
  }
  // array
  else  if (typeof req[method].url == 'object') {
      ui_url = cleanup_list(req[method].url).join(" ");
  }
 
  // single value 
  else if (typeof req[method].url == 'string') {
      ui_url = req[method].url;
  
  } else {
    return res.send(JSON.stringify({status: 503, message: 'missing url parameter' }));
  }
  
  var command = 'env stripes_tenant="' + tenant + '"' + ' ui_url="' + ui_url;
  command += '" ./bin/tenant-bundle.sh';
  
  if (debug >= 1) {
    console.log("Run shell command: " + command)
  }
  
  exec(command,  (error, stdout, stderr) => {

    if (error) {
        console.log(error)
        return res.send(JSON.stringify({status: 503, message: 'webpack exit with non-zero status' }));
    };
    
    if (debug >= 1) {
      console.log('Run build, may take 20-30 seconds, tenant ' + tenant);
      console.log('UI module: ' + JSON.stringify(cleanup_list(req[method].url)))
    }
    
    if (debug >= 1) {
      console.log("Webpack script is done");
    }
    
    if (debug >= 2) {
      console.log(stdout);    // There'll be trailing \n in the output
    }

    var lines = stdout.split("\n");
    lines.pop(); // newline
    var url = lines.pop();
    
    if (debug >= 1) {
        console.log("AWS S3 URL: " + url)
    }
    var aws_url = { status: 201, url: url };
    
    // res.send("get bundle for tenant " + tenant + " " + req.query.url + result);
    res.location(url);
    res.status(201);
   
    if (type == 'get') { 
      res.send(JSON.stringify(aws_url));
    } else {
      res.send("");
    }
  });
};

/**************/
// xxx
var result = [];

function get_ui_modules(list, func) {
    if (!list || list.length == 0) {
        func(result);
        return;
    }

    var m = list.pop();
    var url = "http://localhost:9130/_/proxy/modules/" + m;
    // curl http://localhost:9130/_/proxy/modules/folio-sample-modules-trivial
    // curl http://localhost:9130/_/proxy/modules/trivial

    request(url, function(error, response, body) {
        if (!error && response.statusCode == 200) {
            var obj = JSON.parse(body);
            // console.log(obj)
            if (obj.uiDescriptor) {
                var u = obj.uiDescriptor.url ? obj.uiDescriptor.url : obj.uiDescriptor.npm;
                
                result.push(u);
                if (debug) console.log("found ui module: " + obj.name + " uri: " + u)
            } else {
                if (debug) console.log("found non-module: " + obj.name)
            }

            return get_ui_modules(list, func);
        } else {
            console.log("HTTP status for " + url + " " + response.statusCode);
        }
    });
}


// return a simple module list 


function modules_list(modules) {
    var list = [];
    for (var i = 0; i < modules.length; i++) {
        list.push(modules[i].id);
    }

    return list;
}

function get_module_list(tenant, func, res) {
    // curl http://localhost:9130/_/proxy/tenants/demo/modules
    var url = "http://localhost:9130/_/proxy/tenants/" + tenant + "/modules";

    request(url, function(error, response, body) {
        if (!error && response.statusCode == 200) {
            var modules = JSON.parse(body);
            var list = modules_list(modules);
            
            // filter by ui modules
            get_ui_modules(list, func);

        } else {
            console.log("HTTPs status for " + url + " " + response.statusCode);
            return res.send(JSON.stringify({status: 503, message: 'internal error' }));
        }
    })
}

function body_data(modules) {
    var obj = {
        url: modules
    };

    return JSON.stringify(obj);
};

function webpack_service(tenant, modules, res) {
    var body = body_data(modules);
    var url = 'http://localhost:3030/bundle';
    // Set the headers
    var headers = {
        'X-Okapi-Tenant-Id': tenant,
        'User-Agent': 'Webpack Folio UI Agent/0.1.0',
        'Content-Type': 'application/json'
    }

    // Configure the request
    var options = {
        method: 'POST',
        url: url,
        headers: headers,
        body: body
    }

    if (debug >= 2) console.log(options);

    request(options, function(error, response, body) {
      
        if (!error && response && response.statusCode == 201) {
            var location = response.headers.location
            if (debug >= 2) console.log("result location: " + location)
            
            // push the results back
            res.location(location);
            res.status(201);
            res.send("");
            
        } else {
            if (response) {
              console.log("HTTP status for " + url + " " + response.statusCode);
            } else {
              console.warn("No response, was the service on " + options.url + " started?")
            }
            return res.send(JSON.stringify({status: 503, message: 'internal error' }));
        }
    })
}


function ui_module(tenant, res) {
  if (debug >= 1) console.log("Fetch UI module list for tenant: " + tenant)
  
  // http://localhost:9130/_/proxy/tenants/$tenant/modules
  return get_module_list(tenant, function(modules) {
      webpack_service(tenant, modules, res)
  }, res);
}


app.listen(port, function () {
  console.log('Example app listening on http://localhost:' + port);
});

