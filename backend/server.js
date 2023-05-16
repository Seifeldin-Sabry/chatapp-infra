const mongoose = require('mongoose')
const dotenv = require('dotenv');
dotenv.config({
  path: './config.env',
});

const DB = process.env.DB.replace('<password>', process.env.DB_PASSWORD)

mongoose.connect(DB)
    .then(con => {
  console.log('DB CONNECTION SUCCESS')
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
