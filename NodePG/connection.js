//개발 서버

const {Client} = require('pg')

const client = new Client({
    host: "localhost",
    user: "postgres",
    port: 5432,
    //password: "masterpass11",
    database: "keyManager"
})
module.exports = client


//상용 서버 old(15432 Port)
/*
const {Client} = require('pg')

const client = new Client({
    host: "service.fatos.biz",
    user: "master",
    port: 15432,
    password: "masterpass11",
    database: "keyManager"
})

module.exports = client

*/

//상용 서버 (new) (15432 Port)
/*
const {Client} = require('pg')

const client = new Client({
    host: "service.fatos.biz",
    user: "master",
    port: 15432,
    password: "masterpass11",
    database: "fatosdb"
})

module.exports = client
*/
