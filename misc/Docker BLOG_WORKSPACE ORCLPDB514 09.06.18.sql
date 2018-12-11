set serveroutput on
declare
l_list_id varchar2(100);
begin
blog_mailchimp_pkg.create_list( p_list_name           => '090618 list',
                                p_permission_reminder => 'your reminder',
                                p_list_id             => l_list_id);
                                
dbms_output.put_line(l_list_id); --ac1610c2bb
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.add_subscriber ( p_list_id => 'ac1610c2bb',
                                    p_email   => 'haydenhhudson@gmail.com',
                                    p_fname   => 'Hayden',
                                    p_lname   => 'Hudson',
                                    p_success => l_success);
if l_success then
dbms_output.put_line('success');
else
dbms_output.put_line('failure');
end if;
end;
/
declare
l_merge_id integer;
l_tag      varchar2(100);
begin
blog_mailchimp_pkg.create_merge_field( p_list_id     => 'ac1610c2bb',
                                       p_merge_field => 'Merge090618',
                                       p_merge_id    => l_merge_id,
                                       p_tag         => l_tag);
dbms_output.put_line('l_merge_id :'||l_merge_id); --5
dbms_output.put_line('l_tag :'||l_tag); --MMERGE5
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.update_merge_field ( p_list_id     => 'ac1610c2bb',
                                        p_merge_id    => 5,
                                        p_merge_field => 'Merge090618',
                                        p_merge_value => 'Today is Sept 6th 2018',
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
blog_mailchimp_pkg.create_campaign (  p_list_id      => 'ac1610c2bb',
                                      p_subject_line => '090618 subject line',
                                      p_title        => '090616 title',
                                      p_template_id  => 39405,
                                      p_send_url     => l_send_url);
dbms_output.put_line(l_send_url); --https://us18.api.mailchimp.com/3.0/campaigns/75d7641f83/actions/send
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.send_campaign (p_send_url => 'https://us18.api.mailchimp.com/3.0/campaigns/75d7641f83/actions/send',
                                  p_success  => l_success);
if l_success then
dbms_output.put_line('success');
else
dbms_output.put_line('failure');
end if;
end;
-- SUCCESS!