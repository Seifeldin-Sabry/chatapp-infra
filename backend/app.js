const express = require('express');
const morgan = require('morgan');
const app = express();

// Middelware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}
app.use(express.json());
app.use(express.static(`${__dirname}/public`));
app.use((req, res, next) => {
  req.requestTime = new Date().toISOString();
  next();
});

//middleware for specified endpoints
// chatapp routes
app.use('/api/chats', chatRouter);
app.use('/api/chats/:id/messages', messageRouter);
app.use('/api/login', loginRouter);
app.use('/api/signup', signupRouter);

app.all('*',(req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server`, 404));
})

app.use(globalErrorHandler)

module.exports = app;
