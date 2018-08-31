create or replace package body blog_mailchimp_pkg as 
    
    gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
    g_url_prefix    constant varchar2(100):= 'https://us18.api.mailchimp.com/3.0/';
    g_username      constant varchar2(50) := 'admin';
    g_password      constant varchar2(50) := '186cc40d3bc8e3ce51d8ffe49452d676-us18';
    g_wallet_path   constant varchar2(100):= 'file:/home/oracle/orapki_wallet_nowc';
    g_https_host    constant varchar2(100):= 'wildcardsan2.mailchimp.com';

procedure create_merge_field(p_list_id  in varchar2,
                             p_name     in varchar2,
                             p_merge_id out integer,
                             p_tag      out varchar2)
is 
l_scope    logger_logs.scope%type := gc_scope_prefix || 'create_merge_field';
l_params   logger.tab_param;
l_url      varchar2(2000);
l_token    varchar2(2000);
l_clob     clob;
l_response varchar2(2000);
begin 
    logger.append_param(l_params, 'p_list_id', p_list_id);
    logger.append_param(l_params, 'p_name', p_name);
    logger.append_param(l_params, 'p_merge_id', p_merge_id);
    logger.append_param(l_params, 'p_tag', p_tag);
    logger.log('START', l_scope, null, l_params);
    
    l_url := 'https://us18.api.mailchimp.com/3.0/lists/8f79153475/merge-fields';
    l_token := '186cc40d3bc8e3ce51d8ffe49452d676-us18';

    apex_json.initialize_clob_output;
    apex_json.open_object;       
    apex_json.write('name', 'BLOGPOST');    
    apex_json.write('type', 'text');
    apex_json.close_all;                              
    l_clob := apex_json.get_clob_output;                      
    apex_json.free_output;

    l_response := apex_web_service.make_rest_request(
          p_url         => l_url
        , p_http_method => 'GET'
        , p_username    => 'BLERG' 
        , p_password    =>  l_token
        , p_body        =>  l_clob
        , p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
        , P_HTTPS_HOST => 'wildcardsan2.mailchimp.com'
    );

    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_merge_field;

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

    l_body := '{"name":"'||p_merge_field||'", "type":"text", "default_value": "'||p_merge_value||'", "options": {"size": 500}}';

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

procedure create_campaign ( p_list_id      in varchar2,
                            p_subject_line in varchar2,
                            p_title        in varchar2,
                            p_template_id  in number,
                            p_reply_to     in varchar2,
                            p_from_name    in varchar2,
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
    logger.append_param(l_params, 'p_reply_to', p_reply_to);
    logger.append_param(l_params, 'p_from_name', p_from_name);
    logger.append_param(l_params, 'p_send_url', p_send_url);
    logger.log('START', l_scope, null, l_params);
    l_body         := '{"recipients":{"list_id":"'||p_list_id||'"},"type":"regular","settings":{"subject_line":"'||p_subject_line||'", "title": "'||p_title||'","template_id": '||p_template_id||',"reply_to":"'||p_reply_to||'","from_name":"'||p_from_name||'"}}';

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
end;

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