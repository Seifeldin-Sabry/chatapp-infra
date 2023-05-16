const express = require('express');
const router = express.Router();
const {getChats} = require("../controllers/userController");

router.route('/:user/chats')
    .get(getChats)




module.exports = router;
