const sql = require("../utils/db.js");

exports.signUp = async (req, res, next) => {
  const { name, password} = req.body

  let userExists = await sql`
    select * from platform_user
    where name = ${name}
    `
  if (userExists.length > 0){
    console.log("user already exists")
    res.status(400).json({
      status: "fail",
      message: "user already exists"
    })
    return
  }

  const newUser = await sql`
       insert into platform_user
      (name, password)
    values
      (${ name }, ${ password })
    returning name, password`

    res.status(201).json({
        status: "success",
        data: {
          user: newUser
        }
    })
}

exports.login = async (req, res, next) => {
  const { name, password } = req.body

  //steps to login
  let userExists = await sql`
       select * from platform_user
       where name = ${name} 
         and password = ${password}`

  if (userExists.length === 0){
    console.log("user does not exist")
      res.status(404).json({
          status: "fail",
          message: "user does not exist"

      })
      return
  }

    res.status(200).json({
        status: "success",
        data: {
            user: userExists[0]
        }
    })
}
