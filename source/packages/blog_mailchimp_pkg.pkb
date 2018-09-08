create or replace package body blog_mailchimp_pkg as 
    
    gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.'; --------------- necessary for the logger implementation
    g_url_prefix    constant varchar2(100):= 'https://us18.api.mailchimp.com/3.0/'; ---- your Mailchimp url prefix (see instructions)
    g_company_name  constant varchar2(100):= '2122'; ----------------------------------- whatever your organization is called
    g_reply_to      constant varchar2(100):= 'hhudson@insum.ca'; ----------------------- the email that you've authenticated with Mailchimp
    g_from_name     constant varchar2(100):= 'Hayden Hudson'; -------------------------- the name your emails will appear to be from
    g_username      constant varchar2(50) := 'admin'; ---------------------------------- arbitrary - can be anything
    g_password      constant varchar2(50) := '186cc40d3bc8e3ce51d8ffe49452d676-us18'; -- this is your API Key (very sensitive - keep to yourself)
    g_wallet_path   constant varchar2(100):= 'file:/home/oracle/orapki_wallet_nowc'; --- the path on to your Oracle Wallet
    g_https_host    constant varchar2(100):= 'wildcardsan2.mailchimp.com'; ------------- necessary if you have an Oracle 12.2 database or higher (see instructions)

-- see package specs
function create_list (p_list_name           in varchar2, 
                      p_permission_reminder in varchar2) 
                      return varchar2
is 
l_scope logger_logs.scope%type := gc_scope_prefix || 'create_list';
l_params logger.tab_param;
l_body         varchar2(1000);
l_response     clob;
l_confirmation varchar2(1000);
l_list_id      varchar2(50);
begin
  logger.append_param(l_params, 'p_list_name', p_list_name);
  logger.append_param(l_params, 'p_permission_reminder', p_permission_reminder);
  logger.log('START', l_scope, null, l_params);

    l_body := '{"name":"'||p_list_name||'","contact":{"company":"'||g_company_name||'","address1":"","city":"","state":"","zip":"","country":"","phone":""},"permission_reminder":"'||p_permission_reminder||'","campaign_defaults":{"from_name":"'||g_from_name||'''","from_email":"'||g_reply_to||'","subject":"","language":"en"},"email_type_option":true}';

    logger.log('l_body :'||l_body, l_scope, null, l_params);

    l_response := apex_web_service.make_rest_request(
          p_url         => g_url_prefix||'/lists/'
        , p_http_method => 'POST'
        , p_username    => g_username
        , p_password    => g_password
        , p_body        => l_body
        , p_wallet_path => g_wallet_path
        , p_https_host  => g_https_host
    );

    l_list_id := json_value(l_response, '$.id');

    logger.log('list id :'    ||l_list_id , l_scope, null, l_params);
    logger.log('l_response : '||l_response, l_scope, null, l_params);

  logger.log('END', l_scope);
  return l_list_id;
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_list;

-- see package specs
procedure add_subscriber (  p_list_id in varchar2,
                            p_email   in varchar2,
                            p_fname   in varchar2,
                            p_lname   in varchar2,
                            p_success out boolean)
is 
l_scope        logger_logs.scope%type := gc_scope_prefix || 'add_subscriber';
l_params       logger.tab_param;
l_body         varchar2(1000);
l_response     clob;
l_confirmation varchar2(1000);
begin
    logger.append_param(l_params, 'p_list_id', p_list_id);
    logger.log('START', l_scope, null, l_params);

    l_body := '{"email_address":"'||p_email||'","status":"subscribed","merge_fields":{"FNAME":"'||p_fname||'","LNAME":"'||p_lname||'"}}';

    l_response := apex_web_service.make_rest_request(
                  p_url         => g_url_prefix||'/lists/'||p_list_id||'/members/'
                , p_http_method => 'POST'
                , p_username    => g_username
                , p_password    => g_password
                , p_body        => l_body
                , p_wallet_path => g_wallet_path
                , p_https_host  => g_https_host
            );

    logger.log('l_response :'||l_response, l_scope, null, l_params);

    l_confirmation := json_value(l_response, '$.status');
    

    if l_confirmation = 'subscribed' then
        p_success := true;
        logger.log('Success! :'||l_confirmation, l_scope, null, l_params);
    else 
        p_success := false;
        logger.log('Failure :'||l_response, l_scope, null, l_params);
    end if;

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end add_subscriber;

-- see package specs
procedure create_merge_field(p_list_id     in varchar2,
                             p_merge_field in varchar2,
                             p_merge_id    out integer,
                             p_tag         out varchar2)
is 
l_scope    logger_logs.scope%type := gc_scope_prefix || 'create_merge_field';
l_params   logger.tab_param;
l_body     varchar2(1000);
l_response varchar2(2000);
begin 
    logger.append_param(l_params, 'p_list_id', p_list_id);
    logger.append_param(l_params, 'p_merge_field', p_merge_field);
    logger.append_param(l_params, 'p_merge_id', p_merge_id);
    logger.append_param(l_params, 'p_tag', p_tag);
    logger.log('START', l_scope, null, l_params);

    /*apex_json.initialize_clob_output;
    apex_json.open_object;       
    apex_json.write('name', 'BLOGPOST');    
    apex_json.write('type', 'text');
    apex_json.close_all;                              
    l_clob := apex_json.get_clob_output;                      
    apex_json.free_output;*/

    l_body := '{"name":"'||p_merge_field||'", "type":"text"}';

    l_response := apex_web_service.make_rest_request(
          p_url         => g_url_prefix||'lists/'||p_list_id||'/merge-fields/'
        , p_http_method => 'POST'
        , p_username    => g_username 
        , p_password    => g_password
        , p_body        => l_body
        , p_wallet_path => g_wallet_path
        , p_https_host  => g_https_host
    );

    p_merge_id := json_value(l_response, '$.merge_id');
    p_tag      := json_value(l_response, '$.tag');

    logger.log(l_response, l_scope, null, l_params);

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_merge_field;

-- see package specs
procedure update_merge_field (p_list_id     in varchar2,
                              p_merge_id    in number,
                              p_merge_field in varchar2,
                              p_merge_value in varchar2,
                              p_success     out boolean)
is 
l_scope        logger_logs.scope%type := gc_scope_prefix || 'update_merge_field';
l_params       logger.tab_param;
l_body         varchar2(1000);
l_response     clob;
l_confirmation varchar2(1000);
begin
  logger.append_param(l_params, 'p_list_id', p_list_id);
  logger.append_param(l_params, 'p_merge_id', p_merge_id);
  logger.append_param(l_params, 'p_merge_value', p_merge_value);
  logger.log('START', l_scope, null, l_params);

    l_body := '{"name":"'||p_merge_field||'", "type":"text", "default_value": "'||p_merge_value||'", "options": {"size": 2000}}';

        l_response := apex_web_service.make_rest_request(
                p_url         => g_url_prefix||'/lists/'||p_list_id||'/merge-fields/'||p_merge_id
                , p_http_method => 'PATCH'
                , p_username    => g_username
                , p_password    => g_password
                , p_body        => l_body
                , p_wallet_path => g_wallet_path
                , p_https_host  => g_https_host
            );

    l_confirmation := json_value(l_response, '$.default_value');
    

    if l_confirmation = p_merge_value then
        p_success := true;
        logger.log('Success! :'||l_confirmation, l_scope, null, l_params);
    else 
        p_success := false;
        logger.log('Failure :'||l_confirmation, l_scope, null, l_params);
    end if;


  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end update_merge_field;

-- see package specs
procedure create_template ( p_template_name in  varchar2, 
                            p_html          in  clob, 
                            p_template_id   out integer)
is 
l_scope    logger_logs.scope%type := gc_scope_prefix || 'create_template';
l_params   logger.tab_param;
l_body     varchar2(1000);
l_response clob;
begin
  logger.append_param(l_params, 'p_template_name', p_template_name);
  logger.log('START', l_scope, null, l_params);

    l_body := '{"name":"'||p_template_name||'","html":"'||p_html||'"}';    
    l_response := apex_web_service.make_rest_request(
                  p_url         => g_url_prefix||'/templates'
                , p_http_method => 'POST'
                , p_username    => g_username
                , p_password    => g_password
                , p_body        => l_body
                , p_wallet_path => g_wallet_path
                , p_https_host  => g_https_host
            );
    
    p_template_id := json_value(l_response, '$.id');
    logger.log('p_template_id :'||p_template_id, l_scope, null, l_params);

  logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end;

-- see package specs
procedure update_template ( p_template_id in integer,
                            p_html        in clob,
                            p_success     out boolean)
is
l_scope       logger_logs.scope%type := gc_scope_prefix || 'update_template';
l_params      logger.tab_param;
l_body        clob;
l_response    clob;
l_template_id integer;
begin
    logger.append_param(l_params, 'p_template_id', p_template_id);
    logger.log('START', l_scope, null, l_params);
    
    l_body := '{"html":"'||p_html||'"}';

    l_response := apex_web_service.make_rest_request(
                  p_url         => g_url_prefix||'/templates/'||p_template_id
                , p_http_method => 'PATCH'
                , p_username    => g_username
                , p_password    => g_password
                , p_body        => l_body
                , p_wallet_path => g_wallet_path
                , p_https_host  => g_https_host
            );

    l_template_id := json_value(l_response, '$.id');

    if l_template_id = p_template_id then
        p_success := true;
    else
        p_success := false;
    end if;

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end;

-- see package specs
procedure create_campaign ( p_list_id      in varchar2,
                            p_subject_line in varchar2,
                            p_title        in varchar2,
                            p_template_id  in number,
                            p_send_url     out varchar2)
is
l_scope    logger_logs.scope%type := gc_scope_prefix || 'create_campaign'; 
l_params   logger.tab_param;
l_body     varchar2(1000);
l_response clob;
begin
    logger.append_param(l_params, 'p_list_id', p_list_id);
    logger.append_param(l_params, 'p_subject_line', p_subject_line);
    logger.append_param(l_params, 'p_title', p_title);
    logger.append_param(l_params, 'p_template_id', p_template_id);
    logger.append_param(l_params, 'g_reply_to', g_reply_to);
    logger.append_param(l_params, 'g_from_name', g_from_name);
    logger.append_param(l_params, 'p_send_url', p_send_url);
    logger.log('START', l_scope, null, l_params);
    l_body         := '{"recipients":{"list_id":"'||p_list_id||'"},"type":"regular","settings":{"subject_line":"'||p_subject_line||'", "title": "'||p_title||'","template_id": '||p_template_id||',"reply_to":"'||g_reply_to||'","from_name":"'||g_from_name||'"}}';

    l_response := apex_web_service.make_rest_request(
                      p_url         => g_url_prefix||'/campaigns'
                    , p_http_method => 'POST'
                    , p_username    => g_username
                    , p_password    => g_password
                    , p_body        => l_body
                    , p_wallet_path => g_wallet_path
                    , p_https_host  => g_https_host
                );

    p_send_url := json_value(l_response, '$."_links"[3].href');
    logger.log('p_send_url :'||p_send_url, l_scope, null, l_params);

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
end create_campaign;

-- see package specs
procedure send_campaign (p_send_url in varchar2,
                         p_success  out boolean)
is 
l_scope    logger_logs.scope%type := gc_scope_prefix || 'send_campaign';
l_params   logger.tab_param;
l_response clob;
begin
    logger.append_param(l_params, 'p_send_url', p_send_url);
    logger.log('START', l_scope, null, l_params);

    l_response := apex_web_service.make_rest_request(
                          p_url         => p_send_url
                        , p_http_method => 'POST'
                        , p_username    => g_username
                        , p_password    => g_password
                        , p_wallet_path => g_wallet_path
                        , p_https_host  => g_https_host
                    );
    
    if length(l_response) = 0 then
        p_success := true;
        logger.log('Success!', l_scope, null, l_params);
    else 
        p_success := false;
        logger.log('l_response :'||l_response, l_scope, null, l_params);
    end if;

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end send_campaign;

end blog_mailchimp_pkg;
/