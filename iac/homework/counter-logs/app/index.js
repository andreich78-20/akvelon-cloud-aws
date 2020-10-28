const express = require('express');
const AWSXRay = require('aws-xray-sdk');
const AWS = require('aws-sdk');
const mysql = require('mysql');
const config = require('./config');
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

const cloudWatchLogs = new AWS.CloudWatchLogs({apiVersion: config.logs.apiVersion, region: config.logs.region});

app.use(AWSXRay.express.openSegment('MyApp'));

const loggerMiddleware = async function(req, res, next){
  var startedAt = Date.now();
  next();
  const description = await cloudWatchLogs.describeLogStreams({
    logGroupName: config.logs.group,
    logStreamNamePrefix: config.logs.stream
  }).promise();

  var timestamp = Date.now();
  const params = {
    logEvents: [
      {
        message: JSON.stringify({ip: req.ip, processedMs: (timestamp - startedAt)}),
        timestamp: timestamp
      }
    ],
    logGroupName: config.logs.group,
    logStreamName: config.logs.stream,
    sequenceToken: description.logStreams[0].uploadSequenceToken
  };

  await cloudWatchLogs.putLogEvents(params).promise();
};


app.use(loggerMiddleware);

app.get('/', (req, res) => {
  mysqlConnection.query("CALL GetIncrementedVisitorsCounter();", [], (err, rows, fields) => {
    if (!err) {
      var element = rows[0];
      if(element.constructor == Array) {
        res.locals.counter = element[0].IncrementedCounter;
        res.send({ok: 1, pid: process.pid, counter: res.locals.counter});
      }
      else {
        res.send({ok: 0, pid: process.pid, element: element});
      }
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

app.use(AWSXRay.express.closeSegment());

const port = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

app.listen(port, () => {
  console.log(`App started on port ${port}`);
});
