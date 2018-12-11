create table hhh_clob (theclob clob, thedate date default sysdate);
/
SET SERVEROUTPUT ON
DECLARE
L_MERGID INTEGER;
L_TAG VARCHAR2(500);
BEGIN
  blog_mailchimp_pkg.create_merge_field(p_list_id  => 'A',
                                        p_name     => 'A',
                                        p_merge_id => L_MERGID,
                                        p_tag      => L_TAG);
  DBMS_OUTPUT.PUT_LINE('L_MERGID'||L_MERGID);
  DBMS_OUTPUT.PUT_LINE('L_TAG'||L_TAG);
END;
/
select * from hhh_clob;
/
/*
https://docs.oracle.com/database/apex-5.1/AEAPI/MAKE_REST_REQUEST-Function.htm#AEAPI1955
APEX_WEB_SERVICE.MAKE_REST_REQUEST(
    p_url               IN VARCHAR2,
    p_http_method       IN VARCHAR2,
    p_username          IN VARCHAR2 default null,
    p_password          IN VARCHAR2 default null,
    p_scheme            IN VARCHAR2 default 'Basic',
    p_proxy_override    IN VARCHAR2 default null,
    p_transfer_timeout  IN NUMBER   default 180,
    p_body              IN CLOB default empty_clob(),
    p_body_blob         IN BLOB default empty_blob(),
    p_parm_name         IN apex_application_global.VC_ARR2 default empty_vc_arr,
    p_parm_value        IN apex_application_global.VC_ARR2 default empty_vc_arr,
    p_wallet_path       IN VARCHAR2 default null,
    p_wallet_pwd        IN VARCHAR2 default null ) 
RETURN CLOB;*/




select 
apex_web_service.make_rest_request(
          p_url         => 'https://us18.api.mailchimp.com/3.0/campaigns'
        , p_http_method => 'POST'
        , p_username    => 'admin'
        , p_password    =>  '186cc40d3bc8e3ce51d8ffe49452d676-us18'
        , p_body        =>  '{"recipients":{"list_id":"8f79153475"}
,"type":"regular"
,"settings":
{"subject_line":"This was created in PLSQL"
, "title": "Check out the latest comment on your blog"
,"template_id": 39405
,"reply_to":"hhudson@insum.ca"
,"from_name":"Hayden Hudson"}
}'
        --, p_parm_name   => 'Content-Type' 
        --, p_parm_value  => 'application/json'
        ,p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
        , P_HTTPS_HOST => 'wildcardsan2.mailchimp.com'
    ) from dual;
    /
select 
apex_web_service.make_rest_request(
          p_url         => 'https://us18.api.mailchimp.com/3.0/lists/8f79153475/merge-fields/5'
        , p_http_method => 'PATCH'
        , p_username    => 'admin'
        , p_password    =>  '186cc40d3bc8e3ce51d8ffe49452d676-us18'
        , p_body        => '{"name":"LATESTCOMMENT", "type":"text", "default_value": "Sharp Objects is pretty good.", "options": {
                "size": 500
            }}'
        ,p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
        , P_HTTPS_HOST => 'wildcardsan2.mailchimp.com'
    ) from dual;
/

select 
apex_web_service.make_rest_request(
          p_url         => 'https://us18.api.mailchimp.com/3.0/campaigns/202722e731/actions/send'
        , p_http_method => 'POST'
        , p_username    => 'admin'
        , p_password    =>  '186cc40d3bc8e3ce51d8ffe49452d676-us18'
        --, p_parm_name   => 'Content-Type' 
        --, p_parm_value  => 'application/json'
        ,p_wallet_path => 'file:/home/oracle/orapki_wallet_nowc'
        , P_HTTPS_HOST => 'wildcardsan2.mailchimp.com'
    ) from dual;
