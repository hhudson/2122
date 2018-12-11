set serveroutput on
declare
l_success boolean;
begin
blog_mailchimp_pkg.add_subscriber (  p_list_id => 'bf376cad99', --- the id of the list you are adding a subscriber to
                                     p_email   => 'haydenhhudson@gmail.com', --- the email of the new subscriber
                                     p_fname   => 'Hayden', --- the 1st name of this subscriber
                                     p_lname   => 'Hudson', --- the last name of this subscriber
                                     p_success => l_success);
if l_success then
  dbms_output.put_line('success');
end if;
end;
/
declare
l_list_id varchar2(50);
begin
l_list_id := blog_mailchimp_pkg.create_list (p_list_name           => 'Main 2122 Blog subscribers', --- the name you want to give your new mailing list
                                p_permission_reminder => 'You signed up for this email distribution.');

dbms_output.put_line(l_list_id); --3ece62edf9
end;
/
begin
logger.purge_all;
end;
/
select * from logger_logs
order by id;
/
select * from blog_posts;