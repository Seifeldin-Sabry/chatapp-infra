const express = require('express');
const router = express.Router();
const {getChats} = require("../controllers/userController");
const {getUsers} = require("../controllers/userController");

router.route('/:user/chats')
    .get(getChats)

router.route('/').get(getUsers)

module.exports = router;
