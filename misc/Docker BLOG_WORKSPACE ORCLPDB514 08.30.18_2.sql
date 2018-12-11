begin
logger.purge_all;
end;
/
set serveroutput on
declare
l_boolean boolean;
begin
blog_mailchimp_pkg.update_merge_field ( p_list_id     => '8f79153475',
                                        p_merge_id    => 5,
                                        p_merge_field => 'LATESTCOMMENT',
                                        p_merge_value => 'I love your blog.',
                                        p_success     => l_boolean);

if l_boolean then
  dbms_output.put_line('success');
else
  dbms_output.put_line('failure');
end if;
end; -->works!
/
declare
l_send_url varchar2(1000);
begin
blog_mailchimp_pkg.create_campaign (p_list_id      => '8f79153475',
                                    p_subject_line => 'This is my subject line',
                                    p_title        => 'This is my title',
                                    p_template_id  => 39405,
                                    p_reply_to     => 'hhudson@insum.ca',
                                    p_from_name    => 'Hayden Hudson',
                                    p_send_url     => l_send_url);

dbms_output.put_line('l_send_url :'||l_send_url); --> https://us18.api.mailchimp.com/3.0/campaigns/87251be3db/actions/send
end; --> works!
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.send_campaign (p_send_url => 'https://us18.api.mailchimp.com/3.0/campaigns/87251be3db/actions/send',
                                  p_success  => l_success);

if l_success then
  dbms_output.put_line('success');
else
  dbms_output.put_line('failure');
end if;
end;
/
select * from logger_logs order by id;
/

select 
apex_web_service.make_rest_request(
          p_url         => 'https://us18.api.mailchimp.com/3.0/lists/'
        , p_http_method => 'POST'
        , p_username    => 'blerg'
        , p_password    =>  '186cc40d3bc8e3ce51d8ffe49452d676-us18'
        , p_body        =>  '{"name":"Hayden test 3 list","contact":{"company":"2122","address1":"","city":"","state":"","zip":"","country":"","phone":""},"permission_reminder":"You are receiving this email because you signed up for updates to the blog comment section.","campaign_defaults":{"from_name":"Hayden Hudson","from_email":"hhudson@insum.ca","subject":"","language":"en"},"email_type_option":true}'
        , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
        , p_https_host => 'wildcardsan2.mailchimp.com'
    ) from dual;
/
