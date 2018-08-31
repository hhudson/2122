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
