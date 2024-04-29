--select * from sitekey.fatos_service where site = 123;
--select md5('A1:B2:C3:D4:E5:F6_123'); //basickey => ukey로 부터 basickey생성(ukey는 예시이며,끝에 123은 site 번호를 붙인것이다.)
--select md5('123_1'); //apikey => site와 site_sub을 조합해 apikey를 생성
--serialkey => serialkey는 아직은 basickey와 같게 끔 한다.


select to_hex(v1.a)
from
(            

             select replace('2022-03-31','-','')::integer as a
)v1;

 
--basic key 생성

             select md5(‘userkey_site’)

             select md5('DC:F7:56:14:78:92_38')

--api key 생성

             select md5(‘site_sitesub’)

             select md5('38_2’)
 
--serial key 생성



select

             overlay(

             overlay(

             overlay(

             overlay(

             overlay(

             overlay(

             overlay(v1.a placing substring(v3.hex,1,1) from 12 + v2.startindex for 1) 

                           placing substring(v3.hex,2,1) from 3 + v2.startindex for 1) 

                           placing substring(v3.hex,3,1) from 14 + v2.startindex for 1) 

                           placing substring(v3.hex,4,1) from 4 + v2.startindex for 1) 

                           placing substring(v3.hex,5,1) from 6 + v2.startindex for 1) 

                           placing substring(v3.hex,6,1) from 18 + v2.startindex for 1) 

                           placing substring(v3.hex,7,1) from 8 + v2.startindex for 1)
         

from

(

             select md5('28:ED:E0:26:40:D2_23') as a

)v1,

(

             select

                           case 

                           when substring(v.a, 1, 1) = '0' then ascii(substring(v.a, 1, 1)) - ascii('0') + 10 

                           when substring(v.a, 1, 1) in ('1','2','3','4','5','6','7','8','9') then ascii(substring(v.a, 1, 1)) - ascii('0')

                           else ascii(substring(v.a, 1, 1)) - ascii('a') +1

                           end::integer as startindex

             from

             (

                           select md5('28:ED:E0:26:40:D2_23') as a

             )v

 )v2,

 
(

             -- expire date(yyyymmdd)를 헥사값으로 변경 -> 예시 결과 : 13613cf

             select to_hex(v.a) as hex

             from

             (            

                           select replace('2032-12-31','-','')::integer as a

             )v

)v3;