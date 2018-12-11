set serveroutput on
declare
l_template_id integer;
begin
blog_mailchimp_pkg.create_template (p_template_name => 'My template name', --- the name you want to give the template
                                    p_html          => '<html><body>This is a test of my procedure.</body></html>', ------- the html of the email template
                                    p_template_id   => l_template_id);
dbms_output.put_line('l_template_id :'||l_template_id);
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.update_template (p_template_id => 46237,
                                    p_html        => '<html><body>This is a really basic email.</body></html>',
                                    p_success     => l_success);
if l_success then
dbms_output.put_line('success');
else
dbms_output.put_line('failure');
end if;
end;
/
declare
l_send_url varchar2(100);
begin
blog_mailchimp_pkg.create_campaign (p_list_id      => 'ac1610c2bb',
                                    p_subject_line => '090818 subject',
                                    p_title        => '090818 title',
                                    p_template_id  => 46237,
                                    p_send_url     => l_send_url);
dbms_output.put_line('l_send_url : '||l_send_url); --https://us18.api.mailchimp.com/3.0/campaigns/8c6a3a3c35/actions/send
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.send_campaign (p_send_url => 'https://us18.api.mailchimp.com/3.0/campaigns/8c6a3a3c35/actions/send',
                                  p_success  => l_success);
if l_success then
dbms_output.put_line('success');
else
dbms_output.put_line('failure');
end if;
end;