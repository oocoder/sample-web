// test-exec.js 


var exec = require('child_process').exec;

var child = exec('npm test', function (error, stdout, stderr) {
    console.log('stdout: ' + stdout);
    console.log('stderr: ' + stderr);
    if (error !== null) {
        console.log('exec error: ' + error);
    }
});




 