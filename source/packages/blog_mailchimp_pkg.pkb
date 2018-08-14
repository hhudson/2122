create or replace package body blog_mailchimp_pkg as 
    gc_scope_prefix constant varchar2(31) := lower($plsql_unit) || '.';

procedure create_merge_field(p_list_id  in varchar2,
                             p_name     in varchar2,
                             p_merge_id out integer,
                             p_tag      out varchar2)
is 
l_scope   logger_logs.scope%type := gc_scope_prefix || 'create_merge_field';
l_params  logger.tab_param;
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
    l_token := '[token]';

    apex_json.initialize_clob_output;
    apex_json.open_object;       
    apex_json.write('name', 'BLOGPOST');    
    apex_json.write('type', 'text');
    apex_json.close_all;                              
    l_clob := apex_json.get_clob_output;                      
    apex_json.free_output;

    l_response := apex_web_service.make_rest_request(
          p_url         => l_url
        , p_http_method => 'POST'
        , p_username    => 'BLERG' 
        , p_password    =>  l_token
        , p_body        =>  l_clob
        , p_parm_name   => 'Content-Type' 
        , p_parm_value  => 'application/json'
    );


    logger.log('END', l_scope);
exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
end create_merge_field;

end blog_mailchimp_pkg;