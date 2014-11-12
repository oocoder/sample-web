var https = require('https'),
    pem = require('pem');
process.env.PEMJS_TMPDIR = "./tmp";
var fs = require("fs");
try {
    fs.mkdirSync("./tmp");
} catch (e) {}

    
pem.createCertificate(function(error, data){
    var certificate = (data && data.certificate || "").toString();
    test.ifError(error);
    test.ok(certificate);
    test.ok(certificate.match(/^\n*\-\-\-\-\-BEGIN CERTIFICATE\-\-\-\-\-\n/));
    test.ok(certificate.match(/\n\-\-\-\-\-END CERTIFICATE\-\-\-\-\-\n*$/));

    test.ok((data && data.clientKey) != (data && data.serviceKey));

    test.ok(data && data.clientKey);
    test.ok(data && data.serviceKey);
    test.ok(data && data.csr);
    test.ok(fs.readdirSync("./tmp").length == 0);
    test.done();
});
