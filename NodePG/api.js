/*lt -p 3300 --subdomain mogoskeyadmin --print-\n-requests*/
var https = require('https');
const fs = require('fs');
/*var options = {
    key: fs.readFileSync('key.pem'),
    cert : fs.readFileSync('cert.pem')
};*/
var port = 3400;
const http = require('http');

const client = require('./connection.js')
const express = require('express');
const secure = require('express-force-https');


const bodyParser = require("body-parser");
const cors = require("cors");
const exp = require('constants');


const app = express();


app.use(cors());
app.use(express.urlencoded());
app.use(bodyParser.json());
app.use(secure);

https.createServer(app).listen(port,function(){
    console.log("HTTPS server listening on port");
});
app.listen(3300, ()=>{
    console.log("Server is now listening at port 3300");
});


client.connect();

app.get('/sitekey', (req,res)=>{
    client.query(`Select site,site_sub,site_name,to_char(regdate,'YYYY-MM-DD') as regdate ,to_char(expiredate,'YYYY-MM-DD') as expiredate from sitekey.fatos_service order by site,site_sub`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_service 조회

app.get('/sitekey/distinct_site', (req,res)=>{
    client.query('select site,min(site_name) as site_name from sitekey.fatos_service group by site order by site;', (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_service 조회 site 필터링해서 
   //fatos_service 조회 name도 출력 (임시)
app.get('/sitekey/:site/distinct_sub', (req,res)=>{
    client.query(`Select site_sub from sitekey.fatos_service where site = ${req.params.site} order by site_sub`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_service 조회 site_sub만 필터링해서(생성시 dropdownvalue 활용 그리고 사이트 생성시 중복여부를 위한 용도)


app.get('/sitekey/:site/:site_sub/getsitename', (req,res)=>{
    client.query(`Select site_name from sitekey.fatos_service where site = ${req.params.site} and site_sub = ${req.params.site_sub}`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_service 조회 site_name만 출력하기

/*app.get('/sitekey/getsitename', (req,res)=>{
    client.query(`select min(site_name) as site_name from sitekey.fatos_service group by site order by site`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_service 조회 site_name만 출력하기 2(dropdownvalue에서 보여주기용 )
*/




app.post('/sitekey', (req,res)=>{
    const sitekey = req.body;
    let insertQuery = `insert into sitekey.fatos_service(site,site_sub,site_name,regdate,expiredate) \
    values(${sitekey.site},${sitekey.site_sub},'${sitekey.site_name}','${sitekey.regdate}','${sitekey.expiredate}') `

    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_service 데이터 삽입
app.put('/sitekey/update/:site/:site_sub', (req, res)=> {
    const sitekey = req.body;
    let updateQuery =`update sitekey.fatos_service  set site_name = '${sitekey.site_name}',expiredate = '${sitekey.expiredate}' where site = ${req.params.site} and site_sub =${req.params.site_sub}`

    client.query(updateQuery, (err, result)=>{
        if(!err){
            res.send('수정 성공')
        }
        else{ console.log(err.message) }
    })
    client.end;
})//fatos_service 데이터 수정


app.delete('/sitekey/delete/:site/:site_sub', (req, res)=> {
    
    let insertQuery = `delete from sitekey.fatos_service where site=${req.params.site} and site_sub = ${req.params.site_sub}`

    client.query(insertQuery, (err, result)=>{
        if(!err){
            res.send('Deletion was successful')
        }
        else{ console.log(err.message) }
    })
    client.end;
})
//fatos_service 데이터 삭제



app.get('/getauthex', (req, res)=>{
    client.query('Select * from sitekey.fatos_authex', (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
})
//fatos_authex 데이터 조회(1)

app.get('/getauthex/:site/:site_sub', (req,res)=>{
    client.query(`Select * from sitekey.fatos_authex where site = ${req.params.site} and site_sub = ${req.params.site_sub} and created = current_date order by ukey`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_authex 조회(2)
app.get('/getauthex2/:site/:site_sub', (req,res)=>{
    client.query(`Select ukey,to_char(created,'YYYY-MM-DD') as created ,to_char(expire, 'YYYY-MM-DD') as expire from sitekey.fatos_authex where site = ${req.params.site} and site_sub = ${req.params.site_sub} order by ukey`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //fatos_authex 조회(3)

app.get('/getauthex2/makedb/:site/:site_sub',(req,res)=>{
    client.query(`SELECT DISTINCT on (SERIALKEY) SERIALKEY FROM sitekey.fatos_authex  WHERE (SITE = 1 AND SITE_SUB = 0) OR (SITE = ${req.params.site} AND SITE_SUB >= 100 AND EXPIRE >= CURRENT_TIMESTAMP) ORDER BY SERIALKEY ASC`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
})//fatos_authex db 생성 쿼리 (소방청 전용)
app.get('/getauthex2/makedb2/:site/:site_sub',(req,res)=>{
    client.query(`SELECT DISTINCT on (SERIALKEY) SERIALKEY FROM sitekey.fatos_authex  WHERE (SITE = 1 AND SITE_SUB = 0) OR (SITE = ${req.params.site} AND SITE_SUB < 100 AND EXPIRE >= CURRENT_TIMESTAMP) ORDER BY SERIALKEY ASC`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
})//fatos_authex db 생성 쿼리 (그외 사이트들)
app.get('/getauthex2/makedb3/:site/:site_sub',(req,res)=>{
    client.query(`SELECT ukey as mac, SERIALKEY FROM sitekey.fatos_authex  WHERE SITE = ${req.params.site} AND SITE_SUB = ${req.params.site_sub} AND created = current_date ORDER BY SERIALKEY ASC`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
})//fatos_authex db 생성 쿼리 (도로공사)



/*app.post('/authex', (req,res)=>{
    const authex = req.body;
    let insertQuery = `insert into sitekey.fatos_authex(site,site_sub,ukey,apikey,basickey,serialkey,created,expire,device) \
    values(${authex.site},${authex.site_sub},'${authex.ukey}','${authex.apikey}','${authex.basickey}','${authex.serialkey}','${authex.created}','${authex.expire}','${authex.device}') `

    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_authex 데이터 삽입
*/
app.delete('/authex/delete/:site/:site_sub/:ukey', (req, res)=> {
    const authex = req.body;
    let deleteQuery = `delete from sitekey.fatos_authex where site = ${req.params.site} and site_sub = ${req.params.site_sub} and ukey='${req.params.ukey}'`
    client.query(deleteQuery, (err, result)=>{
        if(!err){
            res.send('삭제 성공')
        }
        else{ console.log(err.message) }
    })
    client.end;
})//fatos_authex 데이터 삭제 (단일 키만)

app.delete('/authex/delete/:site/:site_sub', (req, res)=> {
    const authex = req.body;
    let deleteQuery = `delete from sitekey.fatos_authex where site = ${req.params.site} and site_sub = ${req.params.site_sub}`
    client.query(deleteQuery, (err, result)=>{
        if(!err){
            res.send('삭제 성공')
        }
        else{ console.log(err.message) }
    })
    client.end;
})//fatos_authex 데이터 삭제 (사이트의 키 전부)




 

app.post('/authex/:site/:site_sub/:ukey/:device', (req,res)=>{
    const authex = req.body;
    let insertQuery = `insert into sitekey.fatos_authex(site,site_sub,ukey,apikey,basickey,serialkey,created,expire,device)\
    values(${req.params.site},${req.params.site_sub},'${req.params.ukey}',md5(concat(${req.params.site},'_',${req.params.site_sub})),\
    md5(concat('${req.params.ukey}','_',${req.params.site})),md5(concat('${req.params.ukey}','_',${req.params.site})),\
    (select current_date),\
    (select expiredate from sitekey.fatos_service where site = ${req.params.site} and site_sub = ${req.params.site_sub}), '${req.params.device}')`


    
    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_authex 데이터 삽입(new)
app.post('/authex2/:site/:site_sub/:ukey/:device', (req,res)=>{
    const authex = req.body;
    let insertQuery = `insert into sitekey.fatos_authex(site,site_sub,ukey,apikey,basickey,serialkey,created,expire,device)\
    values(${req.params.site},${req.params.site_sub},'${req.params.ukey}',md5(concat(${req.params.site},'_',${req.params.site_sub})),\
    md5(concat('${req.params.ukey}','_',${req.params.site})),md5(concat('${req.params.ukey}','_fatosauto')),\
    (select current_date),\
    (select expiredate from sitekey.fatos_service where site = ${req.params.site} and site_sub = ${req.params.site_sub}), '${req.params.device}')`


    
    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_authex 데이터 삽입(도공 버전)
app.post('/authex/:site/:site_sub/:ukey', (req,res)=>{
    const authex = req.body;
    let insertQuery = `insert into sitekey.fatos_authex(site,site_sub,ukey,apikey,basickey,serialkey,created,expire,device)\
    values(${req.params.site},${req.params.site_sub},'${req.params.ukey}',md5(concat(${req.params.site},'_',${req.params.site_sub})),\
    md5(concat('${req.params.ukey}','_',${req.params.site})),md5(concat('${req.params.ukey}','_',${req.params.site})),\
    (select current_date),\
    (select to_date(expiredate,'YYYY-MM-DD') expiredate from sitekey.fatos_service where site = ${req.params.site} and site_sub = ${req.params.site_sub}), 0)`


    
    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_authex 데이터 삽입


app.put('/authex/update/:site/:site_sub/:ukey/:newukey/:expire', (req, res)=> {
    const authex = req.body;
    let updateQuery =`update sitekey.fatos_authex  set ukey = '${req.params.newukey}', basickey = md5(concat('${req.params.newukey}','_',${req.params.site})), serialkey = md5(concat('${req.params.newukey}','_',${req.params.site})), expire = to_date('${req.params.expire}','YYYY-MM-DD') where ukey = '${req.params.ukey}' `
    
    client.query(updateQuery, (err, result)=>{
        if(!err){
            res.send('수정 성공')
        }
        else{ console.log(err.message) }
    })
    client.end;
})//fatos_authex 데이터 수정

app.post('/sitekey', (req,res)=>{
    const sitekey = req.body;
    let insertQuery = `insert into sitekey.fatos_service(site,site_sub,site_name,regdate,expiredate) \
    values(${sitekey.site},${sitekey.site_sub},'${sitekey.site_name}','${sitekey.regdate}','${sitekey.expiredate}') `

    client.query(insertQuery,(err,result)=>{
        if(!err){
            res.send('성공!!!!')
        }
        else{console.log(err.message)}
    })
    client.end;
})//fatos_service 데이터 삽입


app.get('/verify1', (req,res)=>{
    client.query(`select site,site_name, expiredate  from sitekey.fatos_service  where current_date > expiredate order by site`, (err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //키 검증( 유효기간 지난 것 출력)



app.get('/verify2', (req,res)=>{
    client.query(`select A.site,A.site_sub,site_name, expiredate  from sitekey.fatos_service A left join sitekey.fatos_authex  B  on A.site = B.site where B.site is null order by site,site_sub`,(err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //키 검증 ( 키 없음)

app.get('/verify3', (req,res)=>{
    client.query(`select A.site,A.site_sub,ukey, expire  from sitekey.fatos_authex A left join sitekey.fatos_service  B  on A.site = B.site and A.site_sub = B.site_sub where B.site is null order by site,site_sub,ukey`,(err,result)=>{
        if(!err){
            res.send(result.rows);
        }
    });
    client.end;
}) //사이트 검증 ( 사이트 없음)



