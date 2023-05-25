const sql = require("../utils/db.js");

exports.getMessages = async (req, res, next) => {
    const {id} = req.params

    const messages = await sql`
        select *
        from message m
        join chat c on m.chat_id = c.chat.id
        where c.chat_id = ${id}`

    res.status(200).json({
        status: "success",
        data: {
            messages
        }
    })
}

exports.getChat = async (userId, receiverId) =>{
    return sql`
        select *
        from chat
        where user1 = ${userId}
            and user2 = ${receiverId}
           or user1 = ${receiverId}
            and user2 = ${userId}`

}

exports.createChat = async (req, res, next) => {
    const {user1, user2} = req.body
    const chat = await sql`
        insert into chat (user1, user2)
        VALUES (${user1}, ${user2}) RETURNING *`

    // const chat2 = await sql `
    //     insert into chat (user2, user1)
    //     VALUES
    //     (${user2}, ${user1})
    //     RETURNING *`
    res.status(201).json({
        status: "success",
        data: {
            chat
        }
    })
}

exports.deleteChat = async (req, res, next) => {
    const {id} = req.params
    const chat = await sql`
        delete from chat
        where id = ${id}`

    if (chat.count === 0) {
        return res.status(404).json({
            status: "fail",
            message: "No chat found with that ID"
        })
    }
    res.status(204).json({
        status: "success"
    });
}

exports.addMessage = async (req, res, next) => {
    const {message, userId} = req.body
    const {id} = req.params

    console.log(message, userId, id)
    const newMessage = await sql`
        insert into message
            (message, sender, chat_id)
        values (${message}, ${userId}, ${id}) returning *`

    res.status(201).json({
        status: "success",
        data: {
            message: newMessage
        }
    })
}

