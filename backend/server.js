const dotenv = require('dotenv');
dotenv.config({
  path: './config.env',
});

const app = require('./app');


/**
 * Starting the Server
 * @type {number}
 */
const port = process.env.PORT || 3002;
const server = app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
const ws = require('ws');
const {parse} = require("url");
const {getChat} = require("./controllers/chatController");

const wsServer = new ws.Server({ server });
wsServer.on('connection', function(ws, req)  {
  const parameters = parse(req.url, true);
  ws.userId=parameters.query.userId;

  ws.on('message', function message(data, isBinary) {
    const message = isBinary ? data : data.toString();
    const jsonMsg= JSON.parse(message);
    if(jsonMsg.type==="message") {
      wsServer.clients.forEach(client => {
        if (client.readyState === 1) {
          if(client.userId===jsonMsg.receiver) {
            client.send(data.toString());
          }
        }
      });
    }
    else {
        wsServer.clients.forEach(client => {
            if (client.readyState === 1) {
            if(client.userId===jsonMsg.receiver) {
              // get chat to add from server
              getChat(jsonMsg.sender, jsonMsg.receiver).then(chat => {
                console.log(chat[0].toString());
                client.send(chat[0].toString());
              });
            }
            }
        });
    }


  });

  ws.on('close', () => {
    // Log a message when a client disconnects
    console.log('Client disconnected');
  });


});

process.on('unhandledRejection', (reason, promise) => {
  console.log('Unhandled Rejection! shutting down...');
  console.log(reason.name, reason.message);
  server.close(() => {
    process.exit(1)
  })
})

process.on('uncaughtException', (error, origin) => {
  console.log('Uncaught Exception! shutting down...');
  console.log(error.name, error.message);
  server.close(() => {
    process.exit(1)
  })
})
