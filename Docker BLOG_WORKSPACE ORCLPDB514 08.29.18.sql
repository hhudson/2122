drop table hhh_clob;
create table hhh_clob (the_clob clob CHECK (the_clob IS JSON), the_desc varchar2(1000),thedate date default sysdate);
/
set serveroutput on
declare
l_response     clob;
l_url_1        varchar2(200) := 'https://us18.api.mailchimp.com/3.0/';
l_username     varchar2(100) := 'admin';
l_password     varchar2(100) := '186cc40d3bc8e3ce51d8ffe49452d676-us18';
l_wallet_path  varchar2(100):= 'file:/home/oracle/orapki_wallet_nowc';
l_https_host   varchar2(100) := 'wildcardsan2.mailchimp.com';
l_list_id      varchar2(100) := '8f79153475';
l_merge_id     number        := 5;
l_merge_field  varchar2(100) := 'LATESTCOMMENT';
l_comment      varchar2(500);
l_body         varchar2(1000);
begin
l_comment := 'This is a great blog.';
l_body := '{"name":"'||l_merge_field||'", "type":"text", "default_value": "'||l_comment||'", "options": {"size": 500}}';

l_response := apex_web_service.make_rest_request(
          p_url         => l_url_1||'/lists/'||l_list_id||'/merge-fields/'||l_merge_id
        , p_http_method => 'PATCH'
        , p_username    => l_username
        , p_password    => l_password
        , p_body        => l_body
        , p_wallet_path => l_wallet_path
        , p_https_host => l_https_host
    );

insert into hhh_clob (the_clob, the_desc) 
values(l_response, 'Updating a merge field');
end;
/
declare
l_response1    clob;
l_response2    clob;
l_url_1        varchar2(200) := 'https://us18.api.mailchimp.com/3.0/';
l_username     varchar2(100) := 'admin';
l_password     varchar2(100) := '186cc40d3bc8e3ce51d8ffe49452d676-us18';
l_body         varchar2(1000);
l_wallet_path  varchar2(100):= 'file:/home/oracle/orapki_wallet_nowc';
l_https_host   varchar2(100) := 'wildcardsan2.mailchimp.com';
l_list_id      varchar2(100) := '8f79153475';
l_template_id  number := 39405;
l_reply_to     varchar2(100) := 'hhudson@insum.ca';
l_from_name    varchar2(200) := 'Hayden Hudson';
l_subject_line varchar2(500);
l_title        varchar2(300);
l_send_url     varchar2(200);
begin

l_subject_line := 'Aug 29 attempt';
l_title        := 'Wow! Check out the latest comment on your blog';
l_body         := '{"recipients":{"list_id":"'||l_list_id||'"},"type":"regular","settings":{"subject_line":"'||l_subject_line||'", "title": "'||l_title||'","template_id": '||l_template_id||',"reply_to":"'||l_reply_to||'","from_name":"'||l_from_name||'"}}';

l_response1 := apex_web_service.make_rest_request(
          p_url         => l_url_1||'/campaigns'
        , p_http_method => 'POST'
        , p_username    => l_username
        , p_password    => l_password
        , p_body        => l_body
        , p_wallet_path => l_wallet_path
        , p_https_host  => l_https_host
    );

insert into hhh_clob (the_clob, the_desc) 
values(l_response, 'Creating a campaign 2');

l_send_url := json_value(l_response1, '$."_links"[3].href');
dbms_output.put_line('l_send_url '||l_send_url);

l_response2 := apex_web_service.make_rest_request(
          p_url         => l_send_url
        , p_http_method => 'POST'
        , p_username    => l_username
        , p_password    => l_password
        , p_wallet_path  => l_wallet_path
        , p_https_host  => l_https_host
    );
end;
/
select hc.the_clob.id, hc.the_clob.emails_sent
, hc.the_clob.recipients.list_name as list_name, hc.the_clob.recipients.recipient_count as recipient_count
, hc.the_clob.settings.subject_line as subject_line
, hc.the_clob."_links"[3].rel as link_type, hc.the_clob."_links"[3].href as send_link
from hhh_clob hc
where the_desc = 'Creating a campaign';
/
declare
l_clob clob;
begin
select hc.the_clob."_links"[3].href
into l_clob
from hhh_clob hc
where the_desc = 'Creating a campaign';
end;
/
declare
l_var varchar2(90);
begin
select json_value(hc.the_clob."_links"[3], '')
into l_var
from hhh_clob hc
where the_desc = 'Creating a campaign';
end;
/

select hc.the_clob.default_value
from hhh_clob hc
where the_desc = 'Updating a merge field';
/
declare
l_response     clob;
l_send_url     varchar2(200);
l_username     varchar2(100) := 'admin';
l_password     varchar2(100) := '186cc40d3bc8e3ce51d8ffe49452d676-us18';
l_wallet_path  varchar2(100):= 'file:/home/oracle/orapki_wallet_nowc';
l_https_host   varchar2(100) := 'wildcardsan2.mailchimp.com';
begin

select hc.the_clob."_links"[3].href as send_link
into l_send_url
from hhh_clob hc
where the_desc = 'Creating a campaign';

l_response := apex_web_service.make_rest_request(
          p_url         => l_send_url
        , p_http_method => 'POST'
        , p_username    => l_username
        , p_password    => l_password
        , p_wallet_path  => l_wallet_path
        , p_https_host  => l_https_host
    );

insert into hhh_clob (the_clob, the_desc) 
values(l_response, 'Sent response');

end;