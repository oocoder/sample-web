// server.js - simple node.js web server
var http = require('http');

const PORT = process.env.PORT || 3000;
const ADDRESS = '0.0.0.0';

var server = http.createServer(function(req, res){
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end(req.headers);    
});

server.listen(PORT, ADDRESS, function(){
    console.log('Server running at http://%s:%d/', ADDRESS, PORT);
    console.log('Press CTRL+C to exit');

    // Check if we are running as root
    if (process.getgid && process.getgid() === 0) {
        process.setgid('nobody');
        process.setuid('nobody');
    }    
});

process.on('SIGTERM', function () {
    if (server === undefined) return;
    server.close(function () {
        // Disconnect from cluster master
        process.disconnect && process.disconnect();
    });
});