begin
logger.purge_all;
end;
/
select * from logger_logs
order by id;
/
--CREATE OR REPLACE TYPE subscribers_t IS TABLE OF VARCHAR2 (100);
/
create TYPE subscriber_typ as object (
    email_address    varchar2(100),
    first_name       VARCHAR2(50),
    last_name        VARCHAR2(50),
    status           varchar2(50)
  );
/
create type subscriber_typ_set as table of subscriber_typ;
/
declare
blerg subscribers_t;
begin
blerg := blog_mailchimp_pkg.get_list_of_subscribers ( p_list_id => '274eee90fb');
end;
/
set serveroutput on
/

--l_response :{"members":[{"id":"8c24736ebb457adf836d90d52e7d02e7","email_address":"donalod@trump.com","unique_email_id":"ac612999f1","email_type":"html","status":"subscribed","merge_fields":{"FNAME":"Hayden","LNAME":"HJdsiuosd","ADDRESS":"","PHONE":""},"stats":{"avg_open_rate":0,"avg_click_rate":0},"ip_signup":"","timestamp_signup":"","ip_opt":"65.96.174.57","timestamp_opt":"2018-09-03T21:07:27+00:00","member_rating":1,"last_changed":"2018-09-06T00:50:07+00:00","language":"","vip":false,"email_client":"","location":{"latitude":0,"longitude":0,"gmtoff":0,"dstoff":0,"country_code":"","timezone":""},"tags_count":0,"tags":[],"list_id":"274eee90fb","_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"update","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"PATCH","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PATCH.json"},{"rel":"upsert","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"PUT","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PUT.json"},{"rel":"delete","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"DELETE"},{"rel":"activity","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/activity","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Activity/Response.json"},{"rel":"goals","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/goals","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Goals/Response.json"},{"rel":"notes","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/notes","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Notes/CollectionResponse.json"},{"rel":"delete_permanent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/actions/delete-permanent","method":"POST"}]},{"id":"c81116a71bb2cc821b2494b9697a3d5f","email_address":"rinalod@trump.com","unique_email_id":"6da307d792","email_type":"html","status":"subscribed","merge_fields":{"FNAME":"Fayden","LNAME":"Fidsiuosd","ADDRESS":"","PHONE":""},"stats":{"avg_open_rate":0,"avg_click_rate":0},"ip_signup":"","timestamp_signup":"","ip_opt":"65.96.174.57","timestamp_opt":"2018-09-03T21:15:19+00:00","member_rating":1,"last_changed":"2018-09-06T00:50:05+00:00","language":"","vip":false,"email_client":"","location":{"latitude":0,"longitude":0,"gmtoff":0,"dstoff":0,"country_code":"","timezone":""},"tags_count":0,"tags":[],"list_id":"274eee90fb","_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"update","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"PATCH","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PATCH.json"},{"rel":"upsert","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"PUT","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PUT.json"},{"rel":"delete","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"DELETE"},{"rel":"activity","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/activity","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Activity/Response.json"},{"rel":"goals","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/goals","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Goals/Response.json"},{"rel":"notes","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/notes","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Notes/CollectionResponse.json"},{"rel":"delete_permanent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/actions/delete-permanent","method":"POST"}]}],"list_id":"274eee90fb","total_items":2,"_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"create","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"POST","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/POST.json"}]}
declare
l_json clob; --:= '{"members":[{"id":"8c24736ebb457adf836d90d52e7d02e7","email_address":"donalod@trump.com","unique_email_id":"ac612999f1","email_type":"html","status":"subscribed","merge_fields":{"FNAME":"Hayden","LNAME":"HJdsiuosd","ADDRESS":"","PHONE":""},"stats":{"avg_open_rate":0,"avg_click_rate":0},"ip_signup":"","timestamp_signup":"","ip_opt":"65.96.174.57","timestamp_opt":"2018-09-03T21:07:27+00:00","member_rating":1,"last_changed":"2018-09-06T00:50:07+00:00","language":"","vip":false,"email_client":"","location":{"latitude":0,"longitude":0,"gmtoff":0,"dstoff":0,"country_code":"","timezone":""},"tags_count":0,"tags":[],"list_id":"274eee90fb","_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"update","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"PATCH","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PATCH.json"},{"rel":"upsert","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"PUT","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PUT.json"},{"rel":"delete","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7","method":"DELETE"},{"rel":"activity","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/activity","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Activity/Response.json"},{"rel":"goals","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/goals","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Goals/Response.json"},{"rel":"notes","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/notes","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Notes/CollectionResponse.json"},{"rel":"delete_permanent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/8c24736ebb457adf836d90d52e7d02e7/actions/delete-permanent","method":"POST"}]},{"id":"c81116a71bb2cc821b2494b9697a3d5f","email_address":"rinalod@trump.com","unique_email_id":"6da307d792","email_type":"html","status":"subscribed","merge_fields":{"FNAME":"Fayden","LNAME":"Fidsiuosd","ADDRESS":"","PHONE":""},"stats":{"avg_open_rate":0,"avg_click_rate":0},"ip_signup":"","timestamp_signup":"","ip_opt":"65.96.174.57","timestamp_opt":"2018-09-03T21:15:19+00:00","member_rating":1,"last_changed":"2018-09-06T00:50:05+00:00","language":"","vip":false,"email_client":"","location":{"latitude":0,"longitude":0,"gmtoff":0,"dstoff":0,"country_code":"","timezone":""},"tags_count":0,"tags":[],"list_id":"274eee90fb","_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"update","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"PATCH","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PATCH.json"},{"rel":"upsert","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"PUT","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/PUT.json"},{"rel":"delete","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f","method":"DELETE"},{"rel":"activity","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/activity","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Activity/Response.json"},{"rel":"goals","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/goals","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Goals/Response.json"},{"rel":"notes","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/notes","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Notes/CollectionResponse.json"},{"rel":"delete_permanent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/c81116a71bb2cc821b2494b9697a3d5f/actions/delete-permanent","method":"POST"}]}],"list_id":"274eee90fb","total_items":2,"_links":[{"rel":"self","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/CollectionResponse.json","schema":"https://us18.api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"},{"rel":"parent","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb","method":"GET","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json"},{"rel":"create","href":"https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members","method":"POST","targetSchema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/Response.json","schema":"https://us18.api.mailchimp.com/schema/3.0/Definitions/Lists/Members/POST.json"}]}';
--l_json clob:= '{"Name" :"Marty"}';
l_response clob;
l_total_items integer;
l_subs subscribers_t := subscribers_t();
l_counter integer;
begin


l_json := apex_web_service.make_rest_request(
                  p_url         => 'https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/'
                , p_http_method => 'GET'
                , p_username    => 'admin'
                , p_password    => '955df428887e5a1f3f1478b250eb1527-us18'
                --, p_body        => l_body
                , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
                , p_https_host  => 'wildcardsan2.mailchimp.com'
            );

l_total_items := json_value(l_json, '$.total_items');
--l_subs.extend(l_total_items + 1);
dbms_output.put_line('l_total_items :'||l_total_items);

--dbms_output.put_line('0 : '||json_value(l_json, '$.members[0].email_address'));
--dbms_output.put_line('1 : '||json_value(l_json, '$.members[1].email_address'));

  /*l_subs.extend(1);
  --l_subs(i) := 'a';
  l_subs(1) := json_value(l_json, '$.members[0].email_address');
  l_subs.extend(1);
  l_subs(2) := json_value(l_json, '$.members[1].email_address');
--l_subs.extend(100);*/

for i in 1..l_total_items 
loop
  l_counter := i -1;
  l_subs.extend(1);
  --l_subs(i) := 'a';
  l_subs(i) := json_value(l_json, '$.members['||l_counter||'].email_address');
end loop;

dbms_output.put_line('l_subs.count :'||l_subs.count);
--dbms_output.put_line('l_subs :'||l_subs(0));

for j in 1..l_subs.count
loop
  dbms_output.put_line(l_subs(j));
end loop;

end;
/
select * from table(blog_mailchimp_pkg.get_list_of_subscribers(p_list_id => 'bf376cad99')) rs
/
declare
TYPE subscriber_typ IS RECORD (
    email_address    varchar2(100),
    first_name       VARCHAR2(50),
    last_name        VARCHAR2(50),
    status           varchar2(50)
  );
type sucscriber_set is table of subscriber_typ;
l_json clob;
l_response clob;
l_total_items integer;
l_subs sucscriber_set := sucscriber_set();
l_counter integer;
begin

l_json := apex_web_service.make_rest_request(
                  p_url         => 'https://us18.api.mailchimp.com/3.0/lists/274eee90fb/members/'
                , p_http_method => 'GET'
                , p_username    => 'admin'
                , p_password    => '955df428887e5a1f3f1478b250eb1527-us18'
                --, p_body        => l_body
                , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
                , p_https_host  => 'wildcardsan2.mailchimp.com'
            );

l_total_items := json_value(l_json, '$.total_items');

for i in 1..l_total_items 
loop
  l_counter := i -1;
  l_subs.extend(1);
  l_subs(i).email_address := json_value(l_json, '$.members['||l_counter||'].email_address');
  l_subs(i).status := json_value(l_json, '$.members['||l_counter||'].status');
  l_subs(i).first_name := json_value(l_json, '$.members['||l_counter||'].merge_fields.FNAME');
  l_subs(i).last_name := json_value(l_json, '$.members['||l_counter||'].merge_fields.LNAME');
end loop;

for j in 1..l_subs.count
loop
  dbms_output.put_line(l_subs(j).email_address);
  dbms_output.put_line(l_subs(j).status);
  dbms_output.put_line(l_subs(j).first_name);
  dbms_output.put_line(l_subs(j).last_name);
end loop;

end;
