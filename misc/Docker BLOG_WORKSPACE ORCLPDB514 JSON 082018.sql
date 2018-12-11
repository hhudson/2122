select json_object(
KEY 'col1' IS d.col1 FORMAT JSON,
KEY 'col2' IS d.col2,
KEY 'col3' IS 'TEXT' FORMAT JSON
) col1
from qz_demo d
order by d.col1;
/
SELECT JSON_OBJECT (
KEY 'col1' IS d.col1,
KEY 'col2' IS d.col2,
KEY 'col3' IS 'TEXT' FORMAT JSON
) col1
from qz_demo d
order by d.col1
/
CREATE TABLE qz_json_data
(
pk_cole NUMBER,
json_col CLOB CHECK (json_col IS JSON)
)
/
INSERT INTO QZ_JSON_DATA VALUES(1, '{"Name" :"Marty"}');
/
select jd.json_col.Name
from qz_json_data jd;
/
Select json_value(jd.json_col, '$.Name') name
from qz_json_data jd
/
Select json_value(jd.json_col, '$.Name' returning varchar2(5)) name
from qz_json_data jd
/
CREATE TABLE plch_json
( always_json    CLOB,
  CONSTRAINT keep_it_real
  CHECK ( always_json IS JSON ) );
/
INSERT INTO plch_json
VALUES(
'{
   "plch_id"     : "1",
   "plch_desc"   : "One",
   "plch_detail" : {
      "detail1" : "1",
      "detail2" : "2",
      "detail3" : [5,4,3,2,1]
                   },
         }'
);
/
select json_value(p.always_json, '$.plch_detail.detail3[4]')
from plch_json p;
/
create table plch_signups (
   signupid    integer generated as identity
 , json_data   clob
 , constraint plch_signups_is_json check (json_data is json)
)
/

insert into plch_signups (json_data) values (
'{
  "FIRSTNAME": "John",
  "LASTNAME": "Smith",
  "SOCIALMEDIA": [
    {
      "SITE": "twitter",
      "ACCOUNT": "@jsmith42"
    },
    {
      "SITE": "linkedin",
      "ACCOUNT": "johnsmithwales"
    }
  ]
}'
)
/

insert into plch_signups (json_data) values (
'{
  "FIRSTNAME": "Mary",
  "LASTNAME": "Jones",
  "SOCIALMEDIA": [
    {
      "SITE": "facebook",
      "ACCOUNT": "marycontrary"
    },
    {
      "SITE": "twitter",
      "ACCOUNT": "@maryjpoppins"
    },
    {
      "SITE": "instagram",
      "ACCOUNT": "@marydarling"
    }  ]
}'
)
/

commit
/
select s.signupid, s.json_data.FIRSTNAME, s.json_data.SOCIALMEDIA.ACCOUNT
from plch_signups s;
/
set serveroutput on
declare
l_fav json_object_t;
l_num number;
begin
  l_fav := json_object_t('{"favorite_flavor":"chocolate"}');
  l_fav.on_error(1);
  l_num := l_fav.get_number('favorite_flavor');
  dbms_output.put_line(l_num);
exception
when value_error
then dbms_output.put_line('Not a number');
end;
/
set serveroutput on
declare
l_colors json_array_t;
begin
l_colors := json_array_t(q'^["Red","Blue","Orange"]^');
dbms_output.put_line(l_colors.get_size);

for indx in 0 .. l_colors.get_size -1
loop
  dbms_output.put_line(l_colors.get_string(indx));
end loop;
end;
/
declare
l_colors json_array_t := json_array_t();
begin
l_colors.append('"Red"');
l_colors.append('Blue');
l_colors.append('Orange');
for indx in 0 .. l_colors.get_size -1
loop
  dbms_output.put_line(l_colors.get_string(indx));
end loop;
end;
/
declare
l_nums json_array_t := json_array_t ('[1,2,3,4,5,6]');
begin
l_nums.remove(1);
l_nums.remove(2);
l_nums.remove(3);
dbms_output.put_line(l_nums.stringify());
end;