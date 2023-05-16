const sql = require("../utils/db.js");

exports.getMessages = async (req, res, next) => {
    const { chatId } = req.params

    const messages = await sql`
        select * from chat
        where ID = ${chatId}`

    res.status(200).json({
        status: "success",
        data: {
            messages
        }
    })
}

exports.createChat = async (req, res, next) => {
    const { user1, user2 } = req.params
    const chat = await sql `
        insert into chat (user1, user2)
        VALUES 
        (${user1}, ${user2})
        RETURNING *`

    res.status(201).json({
        status: "success",
        data: {
            chat
        }
    })
}

exports.addMessage = async (req, res, next) => {
    const { message, userId } = req.body
    const { id } = req.params

    const newMessage = await sql`
        insert into message
        (message, sender, chat_id)
        values
        (${ message }, ${ userId }, ${ id })
        returning *`

    res.status(201).json({
        status: "success",
        data: {
            message: newMessage
        }
    })
}
