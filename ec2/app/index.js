const mysql = require('mysql');
const express = require('express');
const app = express();

var mysqlConnection = mysql.createConnection({
host: process.env.DB_ENDPOINT,
user: process.env.DB_USERNAME,
password: process.env.DB_PASSWORD,
database: process.env.DB_NAME,
multipleStatements: true
});

mysqlConnection.connect((err)=> {
if(!err)
  console.log('Connection established successfully.');
else
  console.log('Connection failed!'+ JSON.stringify(err,undefined,2));
});

app.get('/', (req, res) => {
  mysqlConnection.query("CALL GetIncrementedVisitorsCounter();", [], (err, rows, fields) => {
    if (!err) {
      var element = rows[0];
        if(element.constructor == Array)
          res.send({ok: 1, pid: process.pid, counter: element[0].IncrementedCounter});
        else
          res.send({ok: 0, pid: process.pid, element: element});
    }
    else {
      res.status(500).send({err:err, db: process.env.DB_ENDPOINT});
    }
  });
});

app.get('/long', (req, res) => {
  setTimeout(() => {
    res.send({ok: 1, pid: process.pid})
  }, 5000);
});

app.get('/healthcheck', (req, res) => {
  if (mysqlConnection.state == 'disconnected') {
    res.status(500).send('No connection to the database!');
    return;
  }
  res.send({ok: 1, pid: process.pid, connectionState: mysqlConnection.state});
});

const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

app.listen(port, () => {
  console.log(`app started on port ${port}`);
});
