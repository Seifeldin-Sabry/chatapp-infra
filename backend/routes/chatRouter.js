const express = require('express');
const router = express.Router();
const {
    // deleteChat,
    getMessages,
    addMessage,
    createChat } = require('../controllers/chatController');

router.route('/:id/messages')
    .post(addMessage)

router.route('/:id')
    .get(getMessages)
    // .delete(deleteChat)


router.route('/')
    .post(createChat)

module.exports = router;
