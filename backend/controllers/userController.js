const sql = require("../utils/db.js");

exports.getChats = async (req, res, next) => {
    const {user} = req.params
    const chats = await sql `
        SELECT * from chat
        where user1 = ${user}
        or user2 = ${user}
        `

    res.status(200).json({
        status: "success",
        data: {
            chats
        }
    })
}
exports.getUsers = async (req, res, next) => {
    const {name} = req.params
    const users = await sql `
        SELECT * from PLATFORM_USER
        where name LIKE ${'%' +name + '%'}
        ORDER BY name
        limit 5
        `

    res.status(200).json({
        status: "success",
        data: {
            users
        }
    })
}
