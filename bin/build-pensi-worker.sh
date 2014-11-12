#!/usr/bin/env nodejs
var os = require('os');
var path = require('path');
var fs = require('fs-extra');

var source = 'pensi-worker';
var gitUrl = 'git@bitbucket.org:oocoder/pensi-worker.git';

//process.on('uncaughtException', function(err){ console.error(err)  });

console.log('Starting build process for module:', source);

var workPath = path.join(os.tmpdir(), 'cci-temp');

try { fs.removeSync(workPath) } catch(e) { console.error(e) } // clean up
try { fs.mkdirsSync(workPath) } catch(e) { console.error(e) } // create dir
try { process.chdir(workPath) } catch(e) { console.error(e) } // cd path

console.log('working path:', workPath);

var cmdToExec = [];
cmdToExec.push(function(){ 
    return execSync('git clone ' + gitUrl);
});

cmdToExec.push(function(){ 
    return execSync('sudo docker build .', {cwd: path.join(workPath, source)});
});
// cmdToExec.push(function(){ 
    // return execSync('npm install', {cwd: path.join(workPath, source)});
// });

// cmdToExec.push(function(){ 
    // return execSync('npm test', {cwd: path.join(workPath, source)});
// });

cmdToExec.forEach(function(run){
    var rt = run();
    if(rt.code != 0) return console.error(rt.output);
});


// UTILS FUNCTIONS /////////////////////
function execSync( cmd ){
    console.log('-->', cmd);
    var cp = require('child_process');
    var child = cp.exec.apply(cp, arguments);
    var data = "", code, signal, done = false;
    var ondata = function( chunk ){ data+=chunk };
     
    //child.stdout.setEncoding('utf8');
    // child.stdout.on('data', ondata);
    child.stderr.setEncoding('utf8');
    child.stderr.on('data', ondata);
    
    child.once('close', function( c, s ){
        //child.stdout.removeListener('data', ondata);
        child.stderr.removeListener('data', ondata);
        code = c;
        signal = s;
        done = true;
    });
    
    while(!done) { require('deasync').runLoopOnce() }
    
    return {cmd: cmd, output: data, code: code, signal: signal};
}


/************
Build steps for pensi-worker:

1. Select temp location to put all sources. e.g. $TEMP/src/app
    > $TEMP/src/app
    
2. Get sources 
    a) pensi-worker is source is in git hub under '/oocoder/pensi-worker' url.
        
        * nodejs 0.10.x
        * npm 
        * ssh - to connect to container
        * github keys to pull source code
        * npm install 
        * setup docker run commands (test and run)

    b) run docker image with npm test script. On success restart service
**/    




