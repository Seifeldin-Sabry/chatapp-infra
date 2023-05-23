const postgres = require("postgres")

const sql = postgres({ database: "chatapp", password: "chatapp", user:"postgres", host: "10.26.240.3"})

module.exports = sql
