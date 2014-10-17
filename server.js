// server.js - simple node.js web server
var http = require('http');

var port = process.PORT || 3000;

var serv = http.createServer(function(req, res){
    res.end('Hello World');
});

console.log('Running server on port', port);
serv.listen(port);
