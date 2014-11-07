#!/usr/bin/env nodejs

// Nodejs script to build pensi-worker module

var souce = 'pensi-service';

console.log('build process started for module:', source);

/************
Build Steps: build all the necessary components to run nodejs app 
within docker container
1. Run Docker build steps
    a) We need the following: 
        * debian OS vtag wheezy
        * nodejs 0.10.x
        * npm 
        * ssh - to connect to container
        * github keys to pull source code
        * npm install 
        * setup docker run commands (test and run)

    b) run docker image with npm test script. On success restart service
**/    




