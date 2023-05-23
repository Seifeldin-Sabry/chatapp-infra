const express = require('express');
const morgan = require('morgan');
const app = express();
const chatRouter = require('./routes/chatRouter');
const authRouter = require('./routes/authRouter');
const userRouter = require('./routes/userRouter');
const cors = require('cors');
// Middelware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}


// app.use(cors());
app.use(express.json());
app.use(express.static(`${__dirname}/public`));
app.use((req, res, next) => {
  req.requestTime = new Date().toISOString();
  next();
});

//middleware for specified endpoints
// chatapp routes
app.use('/api/chats', chatRouter);
app.use('/api/auth', authRouter);
app.use('/api/users', userRouter);




module.exports = app;
