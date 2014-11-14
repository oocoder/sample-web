#!/usr/bin/env nodejs
var os = require('os');
var path = require('path');
var fs = require('fs-extra');
var util = require('util');
//var cmdQueue = require('queue')({timeout: 100});

var source = 'pensi-worker';
var gitUrl = 'git@bitbucket.org:oocoder/pensi-worker.git';
var dockImgsPath = '../images';
//process.on('uncaughtException', function(err){ console.error(err)  });

console.log('Starting build process for module:', source);

var workPath = path.join(os.tmpdir(), 'cci-temp');

try { fs.removeSync(workPath) } catch(e) { console.error(e) } // clean up
try { fs.mkdirsSync(workPath) } catch(e) { console.error(e) } // create dir
try { process.chdir(workPath) } catch(e) { console.error(e) } // cd path

console.log('working path:', workPath);
var cmdQueue = [];

// Get sources from repo
cmdQueue.push(function(cb){ 
    execSync('git clone ' + gitUrl, {}, cb);
});

// Get tag name and version
var tag = "";
var version = "";
cmdQueue.push(function(cb){
    try{
        var pkg = require(path.join(workPath, source, 'package.json'));
        version = pkg.version;
        tag = util.format('%s:%s', source.replace(/\./g, '_').replace(/-/g, '_'), 
            pkg.version);
        cb(null, {tag: tag, code: 0});
    } catch(e) { cb(e) }
});


// Run Docker to support the rest of the build process
cmdQueue.push(function(cb){
    execSync(util.format('sudo docker build --force-rm=true -t \"%s\" .', tag), 
        {cwd: path.join(workPath, source)}, cb);
});

// Save Docker image
cmdQueue.push(function(cb){
    var imageFilename = path.join(path.resolve(__dirname,  dockImgsPath), source+'.tgz');
    execSync(util.format('sudo docker save %s | gzip > %s', tag, imageFilename), 
        {}, cb);
});


// Run all commands ////////////////////
processDataAll(cmdQueue, function(err, rs){
    if(err){ console.error(err); console.log('\nBuild failed') }
    else console.log('Build successful');
});

// cmdQueue.start(function(err, results){
    // if(err) return console.error('Build failed:', err);
    
    // console.log('Build successful');
// });

// var cmdToExec = [];
// cmdToExec.push(function(){ 
    // return execSync('git clone ' + gitUrl);
// });

// cmdToExec.push(function(){ 
    // return execSync('sudo docker build .', {cwd: path.join(workPath, source)});
// });
// cmdToExec.push(function(){ 
    // return execSync('npm install', {cwd: path.join(workPath, source)});
// });

// cmdToExec.push(function(){ 
    // return execSync('npm test', {cwd: path.join(workPath, source)});
// });

// cmdToExec.forEach(function(run){
    // var rt = run();
    // if(rt.code != 0) return console.error(rt.output);
// });


// UTILS FUNCTIONS /////////////////////

// Process a series of actions by linking each one until completed
function processDataAll(requests, done){
    _processDataAll(requests, {}, done);
}

function _processDataAll(requests, rs, done){
	var req = requests.shift();
	if(req == undefined) return done(null, rs); // success

    process.nextTick(function(){
        try{
            req(function(err, rs){
                if(err) return done(err, rs);
                
                if(rs.code != 0) 
                    return done(new Error('non-zero exit code. code:' + 
                        rs.code + ', output: ' + rs.output));
                        
                _processDataAll(requests.slice(0), rs, done);
            });
        } catch(e) { return done(e) }
    });
}


function execSync( cmd, opts, callback ){
    console.log('-->', cmd);
    var cp = require('child_process');
    
//    var child = cp.exec.apply(cp, arguments);
    var child = cp.exec(cmd, opts);
    var data = "", code, signal, done = false;
    var ondata = function( chunk ){ data+=chunk };
     
    //child.stdout.setEncoding('utf8');
    // child.stdout.on('data', ondata);
    child.stderr.setEncoding('utf8');
    child.stderr.on('data', ondata);
    child.once('error', function( err ){     
        child.stderr.removeListener('data', ondata);
        child.removeAllListeners('close');
        callback(err); 
    });
    
    child.once('close', function( c, s ){
        //child.stdout.removeListener('data', ondata);
        child.stderr.removeListener('data', ondata);
        code = c;
        signal = s;
        //done = true;
        callback(null, {cmd: cmd, output: data, code: code, signal: signal});
    });
    
    //while(!done) { require('deasync').runLoopOnce() }
    
//    return {cmd: cmd, output: data, code: code, signal: signal};
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




