begin
logger.purge_all;
end;
/
set serveroutput on
declare
l_list_id varchar2(50);
begin
blog_mailchimp_pkg.create_list( p_list_name           => 'My new list',
                                p_permission_reminder => 'You are on this list because you signed up for it',
                                p_list_id             => l_list_id);

  dbms_output.put_line('l_list_id :'||l_list_id); --274eee90fb
end;
/
declare
l_success boolean;
begin
blog_mailchimp_pkg.add_subscriber ( p_list_id => '274eee90fb',
                                    p_email   => 'rinalod@trump.com',
                                    p_fname   => 'Fayden',
                                    p_lname   => 'Fidsiuosd',
                                    p_success => l_success);
if l_success then
  dbms_output.put_line('success');
else
  dbms_output.put_line('failure');
end if;

end;
/
select * from logger_logs order by id;

/
select apex_web_service.make_rest_request(
    p_url         => 'https://us18.api.mailchimp.com', 
    p_http_method => 'GET' 
    ,p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc' 
    , P_HTTPS_HOST => 'wildcardsan2.mailchimp.com'
    ) from dual;