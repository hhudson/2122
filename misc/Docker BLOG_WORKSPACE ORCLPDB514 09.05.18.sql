select apex_web_service.make_rest_request(
      p_url         => 'https://us18.api.mailchimp.com/3.0/' 
    , p_http_method => 'GET' 
    , p_wallet_path => 'file:/home/oracle/wallets/orapki_wallet' 
    , p_https_host  => 'wildcardsan2.mailchimp.com'
    ) from dual;
