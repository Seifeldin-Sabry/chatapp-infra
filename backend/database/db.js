import postgres from "postgres";

const sql = postgres({ database: "chatapp", password: "chatapp", user:"postgres", host: "34.77.249.165"})

export default sql