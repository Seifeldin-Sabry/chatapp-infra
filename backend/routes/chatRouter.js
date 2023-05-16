const express = require('express');
const router = express.Router();
const { getMessages, addMessage, createChat } = require('../controllers/chatController');

router.route('/:id/messages')
    .get(getMessages)
    .post(addMessage)

router.route('/')
    .post(createChat)

module.exports = router;
