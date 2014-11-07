// server.js - simple node.js web server
var http = require('http');
var url = require('url');
var query = require('querystring');

const webHookId = "4455661234";

// var fs = require('fs');
// var options = {
    // key: fs.readFileSync('./keys/domain.key'),
    // cert: fs.readFileSync('./keys/domain.crt')
// };   
    
const PORT = process.env.PORT || 80;
const ADDRESS = '0.0.0.0';
var fullBody = "";
var server = http.createServer(function(req, res){
    // We are only handling post methods for now
    if(req.method !== 'POST'){
        console.error("[405] " + req.method + " to " + req.url);
        res.writeHead(405, "Method not supported", {'Content-Type': 'text/plain'});
        res.end('405 - Method not supported');
        return;
    }
    
    req.setEncoding('utf8');
    req.on('data', function( chunk ){ fullBody+=chunk });
    req.on('end', function(){
        var query = url.parse(req.url, true);
                
        // Call Build Handler 
        if(query.path == '/build'){
            HandleBuildReq(fullBody);
        }
        
        // Return 'OK'
        res.writeHead(200, {'Content-Type': 'text/plain'});
        //JSON.stringify(req.headers)
        res.end(fullBody);
        
    });
    
});

function HandleBuildReq( body ){
    
    var data;
    try{
        //data = JSON.parse(body);
        data = query.parse( body);
    
        //TODO: Need to find a good url parser regex
        var projurl = data.repository.absolute_url.split('/');
        var projname = projurl[projurl.length-1] == '' ? projurl[projurl.length-2] : 
            projurl[projurl.length-1];    
        
        console.log('building project:', projname );

    }catch( err ) {
        console.error('Invalid parse', err, 'object:', body, 'data:', data);
    }
    
    // var buildProjFunc = BuildProjectFunc.create(projname);
    
    // buildProjFunc.run(function( err, results ){
        // if(err) return console.error('Error while running build.', err.message);
    // });
}


server.listen(PORT, ADDRESS, function(){
    console.log('Server running at http://%s:%d/', ADDRESS, PORT);
    console.log('Press CTRL+C to exit');
    
    // Check if we are running as root
    if (process.getgid && process.getgid() === 0) {
        process.initgroups('nobody', 1000);
        process.setgid(1000);
        process.setuid(1000);
    }    
});

process.on('SIGTERM', function () {
    if (server === undefined) return;
    server.close(function () {
        // Disconnect from cluster master
        process.disconnect && process.disconnect();
    });
});