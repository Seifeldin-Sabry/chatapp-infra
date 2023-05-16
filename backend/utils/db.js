const postgres = require("postgres")

const sql = postgres({ database: "chatapp", password: "chatapp", user:"postgres", host: "34.77.249.165"})

module.exports = sql
