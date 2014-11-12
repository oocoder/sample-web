// test.js - Test build api 
var request = require('superagent');
var querystring = require('querystring');
const port = "5414";
const ipAddr = "localhost";

// TODO: Superagent needs to find a better way to handle this
// for development sake! 
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// curl --data @bb.post http://127.0.0.1/build

const  data = { 
    "canon_url": "https://bitbucket.org",
    "commits": [
        {
            "author": "oocoder",
            "branch": "master",
            "files": [
                {
                    "file": "server.js",
                    "type": "modified"
                }
            ],
            "message": "Added some more things to server.js\n",
            "node": "620ade18607a",
            "parents": [
                "702c70160afc"
            ],
            "raw_author": "Alex Maldonado <calidadis@gmail.com>",
            "raw_node": "620ade18607ac42d872b568bb92acaa9a28620e9",
            "revision": null,
            "size": -1,
            "timestamp": "2012-05-30 05:58:56",
            "utctimestamp": "2012-05-30 03:58:56+00:00"
        }
    ],
    "repository": {
        "absolute_url": "/oocoder/pensi-worker/",
        "fork": false,
        "is_private": true,
        "name": "Pensi Worker",
        "owner": "oocoder",
        "scm": "git",
        "slug": "pensi-worker",
        "website": ""
    },
    "user": "oocoder"
}

// process.on('SIGINT', OnClosingHandler); // in case user CTRL-C or Z
// process.on('SIGTERM', OnClosingHandler);
process.on('uncaughtException', function(err){ console.error('failed to send request', err)  });



var payload = querystring.stringify({payload : JSON.stringify(data)}); 

var url = 'https://' + ipAddr + ':' + port + '/build/1223455';
console.log('Sending Bitbucket test payload to:', url);
request
    .post(url)
    .send(payload)
    .set('Accept', '*/*')
    .set('Content-Type', 'application/x-www-form-urlencoded')
    .set('User-Agent', 'Test Build Functionality')
    .end(function(res){
        console.log(res.text);
    });
