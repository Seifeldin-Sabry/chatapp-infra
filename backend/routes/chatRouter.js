const express = require('express');
const router = express.Router();
const { getMessages, addMessage, createChat } = require('../controllers/chatController');

console.log(getMessages)
console.log("HERE")

router.route('/:chatId')
    .get(getMessages)
    .post(addMessage)

router.route('/')
    .post(createChat)


module.exports = router;
