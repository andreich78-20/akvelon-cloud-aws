const mysql = require('mysql');
const express = require('express');
const app = express();

var mysqlConnection = mysql.createConnection({
host: '18.237.56.171',
user: 'dbuser',
password: 'akvelon#cLoudUser2020',
database: 'cloud_test',
multipleStatements: true
});

mysqlConnection.connect((err)=> {
if(!err)
  console.log('Connection established successfully.');
else
  console.log('Connection failed!'+ JSON.stringify(err,undefined,2));
});

  mysqlConnection.query("CALL GetIncrementedVisitorsCounter;", [], (err, rows, fields) => {
    if (!err) {
      rows.forEach( (element) => {
        if(element.constructor == Array)
          console.log(element[0].IncrementedCounter);
        else
          console.log(element);
      });
    }
    else {
      console.log(err);
    }
  });

app.get('/', (req, res) => {
  mysqlConnection.query("CALL GetIncrementedVisitorsCounter;", [], (err, rows, fields) => {
    if (!err)
      rows.forEach( (element) => {
        if(element.constructor == Array)
          res.send(element[0].IncrementedCounter);
        else
          res.send(element);
      });
    else {
      res.status(500);
      res.send(err);
    }
  });
  // res.send({ok: 1, pid: process.pid})
});

app.get('/long', (req, res) => {
  setTimeout(() => {
    res.send({ok: 1, pid: process.pid})
  }, 5000);
});

const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

app.listen(port, () => {
  console.log(`app started on port ${port}`);
});
