var mysql = require('mysql');
var fs = require('fs');
var readline = require('readline');
var myCon = mysql.createConnection({
   host: process.env.MYSQL_HOST,
   port: '3306',
   database: process.env.MYSQL_DATABASE,
   user: process.env.MYSQL_USER,
   password: process.env.MYSQL_PASSWORD
});
var rl = readline.createInterface({
  input: fs.createReadStream('./database.sql'),
  terminal: false
 });
rl.on('line', function(chunk){
    myCon.query(chunk.toString('ascii'), function(err, sets, fields){
     if(err) console.log(err);
    });
});
rl.on('close', function(){
  console.log("finished");
  myCon.end();
});