create or replace PACKAGE BODY  "BLOG_UTIL" 
AS
--------------------------------------------------------------------------------
--the below is part of logger best practices
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Private variables, procedures and functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  TYPE t_author IS RECORD (
    n_author_id     NUMBER(38),
    v_author_name   VARCHAR2(80),
    v_email         VARCHAR2(120),
    v_email_notify  VARCHAR2(1)
  );
  TYPE t_email  IS RECORD (
    v_from          VARCHAR2(120),
    v_subj          VARCHAR2(255),
    v_body          VARCHAR2(32700)
  );
  g_cookie_expires    CONSTANT DATE           := ADD_MONTHS(TRUNC(SYSDATE), 12);
  g_watche_expires    CONSTANT DATE           := ADD_MONTHS(TRUNC(SYSDATE), -1);
  g_cookie_name       CONSTANT VARCHAR2(30)   := '__uid';
  g_cookie_version    CONSTANT VARCHAR2(30)   := '1.0';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_user_name (
    p_user_id IN NUMBER
  ) RETURN VARCHAR2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_user_name';
    l_params logger.tab_param;
    l_user_name VARCHAR2(255);
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.log('START', l_scope, null, l_params);
    SELECT nick_name
    INTO l_user_name
    FROM blog_comment_user
    WHERE user_id = p_user_id
    ;
    logger.log('END', l_scope);
    RETURN l_user_name;
  EXCEPTION WHEN
    NO_DATA_FOUND OR
    VALUE_ERROR OR
    INVALID_NUMBER
  THEN
    apex_debug.warn('blog_util.get_user_name(p_user_id => %s); error: %s', COALESCE(to_char(p_user_id), 'NULL'), sqlerrm);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params);
    Raise;
  when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END get_user_name;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_article_author(
    p_page_id IN NUMBER
  ) RETURN t_author
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_article_author';
    l_params logger.tab_param;
    l_author  t_author;
  BEGIN
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.log('START', l_scope, null, l_params);
    SELECT u.author_id,
      author_name,
      email,
      email_notify
      INTO l_author
    FROM blog_author u
    WHERE u.active = 'Y';
    logger.log('END', l_scope);
    RETURN l_author;
  EXCEPTION WHEN
    NO_DATA_FOUND OR
    VALUE_ERROR OR
    INVALID_NUMBER
  THEN
    apex_debug.warn('blog_util.get_author_record_by_article(p_page_id => %s); error: %s', coalesce(to_char(p_page_id), 'NULL'), sqlerrm);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params); 
    raise;
  when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END get_article_author;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION raw_to_table(
    p_value     IN RAW,
    p_separator IN VARCHAR2 DEFAULT ':'
  ) RETURN apex_application_global.vc_arr2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'raw_to_table';
    l_params logger.tab_param;
    l_value VARCHAR2(32700);
  BEGIN
    logger.append_param(l_params, 'p_value', p_value);
    logger.append_param(l_params, 'p_separator', p_separator);
    logger.log('START', l_scope, null, l_params);
    
    l_value := sys.utl_raw.cast_to_varchar2(p_value);
    l_value := sys.utl_url.unescape(l_value);
    
    logger.log('END', l_scope);
    RETURN apex_util.string_to_table(l_value, COALESCE(p_separator, ':'));
    
    exception when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END raw_to_table;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE set_cookie(
    p_user_id IN NUMBER
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'set_cookie';
    l_params logger.tab_param;
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.log('START', l_scope, null, l_params);

    sys.owa_util.mime_header('text/html', FALSE);
    -- The first element in the table is the cookie version
    -- The second element in the table is the user id
    sys.owa_cookie.send(
      name    => blog_util.g_cookie_name,
      value   => sys.utl_raw.cast_to_raw(blog_util.g_cookie_version || ':' || p_user_id),
      expires => blog_util.g_cookie_expires
    );
    --sys.owa_util.http_header_close;
    logger.log('END', l_scope);
    exception when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END set_cookie;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_cookie
  RETURN NUMBER
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_cookie';
    l_params logger.tab_param;
    l_user_id     NUMBER(38,0);
    l_cookie_val  VARCHAR2(2000);
    l_cookie_vals apex_application_global.vc_arr2;
  BEGIN
    logger.log('START', l_scope);
    l_cookie_val := apex_authentication.get_login_username_cookie(blog_util.g_cookie_name);
    IF l_cookie_val IS NOT NULL THEN
      l_cookie_vals := blog_util.raw_to_table(l_cookie_val);
      -- The first element in the table is the cookie version
      IF l_cookie_vals(1) = blog_util.g_cookie_version THEN
        -- The second element in the table is the user id
        l_user_id := to_number(l_cookie_vals(2));
      END IF;
    END IF;

    logger.log('END', l_scope);
    RETURN l_user_id;
    
  EXCEPTION WHEN
    NO_DATA_FOUND OR
    INVALID_NUMBER OR
    VALUE_ERROR
  THEN
    apex_debug.warn('blog_util.get_cookie; error: %s', sqlerrm);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params); 
    raise;
  when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END get_cookie;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_email_message (
    p_page_title IN VARCHAR2,
    p_article_url   IN VARCHAR2,
    p_blog_name     IN VARCHAR2,
    p_author_name   IN VARCHAR2,
    p_subj          IN VARCHAR2,
    p_body          IN VARCHAR2
  ) RETURN t_email
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_email_message';
    l_params logger.tab_param;
    TYPE tabtype IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(40);
    l_arr   tabtype;
    l_key   VARCHAR2(40);
    l_email t_email;
  BEGIN
    logger.append_param(l_params, 'p_page_title', p_page_title);
    logger.append_param(l_params, 'p_article_url', p_article_url);
    logger.append_param(l_params, 'p_blog_name', p_blog_name);
    logger.append_param(l_params, 'p_author_name', p_author_name);
    logger.append_param(l_params, 'p_subj', p_subj);
    logger.append_param(l_params, 'p_body', p_body);
    logger.log('START', l_scope, null, l_params);

    l_email.v_subj            := apex_lang.message(p_subj);
    l_email.v_body            := apex_lang.message(p_body);
    l_arr('#BLOG_NAME#')      := p_blog_name;
    l_arr('#ARTICLE_TITLE#')  := p_page_title;
    l_arr('#AUTHOR_NAME#')    := p_author_name;
    l_arr('#ARTICLE_URL#')    := p_article_url;  
    l_key := l_arr.FIRST;
    -- Substitude message
    WHILE l_key IS NOT NULL LOOP
      logger.log('l_key not null, therefore prepping email.', l_scope, null, l_params);
      l_email.v_subj := regexp_replace( l_email.v_subj, l_key, l_arr(l_key), 1, 0, 'i' );
      logger.log('l_email.v_sub :'||l_email.v_subj, l_scope, null, l_params);
      l_email.v_body := regexp_replace( l_email.v_body, l_key, l_arr(l_key), 1, 0, 'i' );
      logger.log('l_email.v_body :'||l_email.v_body, l_scope, null, l_params);
      l_key := l_arr.NEXT(l_key);
      logger.log('l_key :'||l_key, l_scope, null, l_params);
    END LOOP;
    /* Get blog email */
    l_email.v_from := blog_util.get_param_value('BLOG_EMAIL');
    logger.log('l_email.v_from :'||l_email.v_from, l_scope, null, l_params);
    --
    logger.log('END', l_scope);
    RETURN l_email;

    exception when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END get_email_message;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_article_url(
    p_page_id  IN NUMBER,
    p_app_alias   IN VARCHAR2,
    p_base_url    IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_article_url';
    l_params logger.tab_param;
    l_url VARCHAR2(2000);
  BEGIN
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_app_alias', p_app_alias);
    logger.append_param(l_params, 'p_base_url', p_base_url);
    logger.log('START', l_scope, null, l_params);

    l_url := 'f?p=' || p_app_alias || ':READ:0::::ARTICLE:' || p_page_id;
    l_url := apex_util.prepare_url(p_url => l_url, p_checksum_type => 'PUBLIC_BOOKMARK');
    l_url := p_base_url || l_url;

    logger.log('END', l_scope);
    RETURN l_url;

    exception when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END get_article_url;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_unsubscribe_url (
    p_user_id     IN NUMBER,
    p_page_id  IN NUMBER,
    p_app_alias   IN VARCHAR2,
    p_base_url    IN VARCHAR2,
    p_page_alias  IN VARCHAR2 DEFAULT 'UNSUBSCRIBE',
    p_session_id  IN NUMBER DEFAULT 0
  ) RETURN VARCHAR2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_unsubscribe_url';
    l_params logger.tab_param;
    l_url       VARCHAR2(2000);
    l_value     VARCHAR2(2000);
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_app_alias', p_app_alias);
    logger.append_param(l_params, 'p_base_url', p_base_url);
    logger.append_param(l_params, 'p_page_alias', p_page_alias);
    logger.append_param(l_params, 'p_session_id', p_session_id);
    logger.log('START', l_scope, null, l_params);

    l_value := sys.utl_raw.cast_to_raw(p_user_id || ':' || p_page_id);
    l_url   := 'f?p=' || p_app_alias || ':UNSUBSCRIBE:' || p_session_id || '::::SUBSCRIBER_ID:' || l_value;
    l_url   := apex_util.prepare_url(p_url => l_url, p_checksum_type => 'PUBLIC_BOOKMARK');
    l_url   := p_base_url || l_url;

    logger.log('END', l_scope);
    RETURN l_url;

    exception when others then 
      logger.log_error('Unhandled Exception', l_scope, null, l_params); 
      raise;
  END get_unsubscribe_url;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_user_attr(
    p_user_id     OUT NOCOPY NUMBER,
    p_email       IN VARCHAR2,
    p_nick_name   IN VARCHAR2,
    p_website     IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'save_user_attr';
    l_params logger.tab_param;
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_email', p_email);
    logger.append_param(l_params, 'p_nick_name', p_nick_name);
    logger.append_param(l_params, 'p_website', p_website);
    logger.log('START', l_scope, null, l_params);
    BEGIN
      INSERT INTO blog_comment_user (email, nick_name, website)
        VALUES (p_email, p_nick_name, p_website)
      RETURNING user_id INTO p_user_id
      ;
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      UPDATE blog_comment_user
        SET nick_name = p_nick_name,
          website = p_website
        WHERE email = p_email
      RETURNING user_id INTO p_user_id
      ;
    END;
  
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END save_user_attr;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_notify_user (
    p_user_id         IN NUMBER,
    p_page_id         IN NUMBER,
    p_followup        IN VARCHAR2
  )
  AS
    l_scope            logger_logs.scope%type := gc_scope_prefix || 'save_notify_user';
    l_params           logger.tab_param;
    l_success          boolean;
    l_list_id          varchar2(50);
    l_comment_user_rec blog_comment_user%rowtype;
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_followup', p_followup);
    logger.log('START', l_scope, null, l_params);

    MERGE INTO blog_comment_notify a
    USING (
      SELECT p_user_id AS user_id,
        p_page_id AS page_id,
        p_followup  AS followup_notify
      FROM DUAL
    ) b
    ON (a.user_id = b.user_id AND a.page_id = b.page_id)
    WHEN MATCHED THEN
      UPDATE SET a.followup_notify = b.followup_notify
    WHEN NOT MATCHED THEN
      INSERT (user_id, page_id, followup_notify)
      VALUES (b.user_id, b.page_id, b.followup_notify)
    ;

    if p_followup = 'Y' then
      begin
        select email_list_id
          into l_list_id
          from blog_posts
          where page_id = p_page_id;
      exception when no_data_found then 
        logger.log_error('No data found in blog_posts table?', l_scope, null, l_params); 
        raise;
      end;

      begin
        select *
          into l_comment_user_rec
          from blog_comment_user
          where user_id = p_user_id;
        
      exception when no_data_found then 
        logger.log_error('No data found in blog_comment_user table?', l_scope, null, l_params); 
        raise;
      end;

           mailchimp_pkg.add_subscriber ( p_list_id => l_list_id, --- the id of the list you are adding a subscriber to
                                          p_email   => l_comment_user_rec.email, --- the email of the new subscriber
                                          p_fname   => l_comment_user_rec.nick_name, --- the 1st name of this subscriber
                                          p_lname   => null, --- the last name of this subscriber
                                          p_success => l_success);
      if l_success then
        logger.log('Subscriber successfully added.', l_scope, null, l_params);
      else 
        logger.log('Subscriber not added for unknown reason.', l_scope, null, l_params);
      end if;

  else 
    logger.log('No followup requested from blog commenter.', l_scope, null, l_params);
  end if;
  
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END save_notify_user;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE notify_author (
    p_page_title IN VARCHAR2,
    p_article_url   IN VARCHAR2,
    p_blog_name     IN VARCHAR2,
    p_author_name   IN VARCHAR2,
    p_author_email  IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'notify_author';
    l_params logger.tab_param;
    l_email t_email;
  BEGIN
    logger.append_param(l_params, 'p_page_title', p_page_title);
    logger.append_param(l_params, 'p_article_url', p_article_url);
    logger.append_param(l_params, 'p_blog_name', p_blog_name);
    logger.append_param(l_params, 'p_author_name', p_author_name);
    logger.append_param(l_params, 'p_author_email', p_author_email);
    logger.log('START', l_scope, null, l_params);

    /* Get email subject and body to variable */
    logger.log('About to fetch the parameters for the email.', l_scope, null, l_params);
    l_email := blog_util.get_email_message(
      p_page_title    => p_page_title,
      p_article_url   => p_article_url,
      p_blog_name     => p_blog_name,
      p_author_name   => p_author_name,
      p_subj          => 'NEW_COMMENT_EMAIL_SUBJ',
      p_body          => 'NEW_COMMENT_EMAIL_BODY'
    );
    /* Send mail to author */
    logger.log('About to send the email to :'||p_author_email, l_scope, null, l_params);
    logger.log('The email should be from :'||l_email.v_from, l_scope, null, l_params);
    logger.log('l_email.v_subj :'||l_email.v_subj, l_scope, null, l_params);
    logger.log('l_email.v_body :'||l_email.v_body, l_scope, null, l_params);
    apex_mail.send (
      p_from => l_email.v_from,
      p_to   => p_author_email,
      p_subj => l_email.v_subj,
      p_body => l_email.v_body
    );
    logger.log('The email should have been added to the APEX MAIL queue.', l_scope, null, l_params);
    /* we do have time wait email sending */
    APEX_MAIL.PUSH_QUEUE;
    logger.log('The queue has been pushed.', l_scope, null, l_params);
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END notify_author;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------  
  PROCEDURE raise_http_error(
    p_id          IN VARCHAR2,
    p_error_code  IN NUMBER DEFAULT 404,
    p_reason      IN VARCHAR2 DEFAULT 'Not Found'
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'raise_http_error';
    l_params logger.tab_param;
  BEGIN
    logger.append_param(l_params, 'p_id', p_id);
    logger.append_param(l_params, 'p_error_code', p_error_code);
    logger.append_param(l_params, 'p_reason', p_reason);
    logger.log('START', l_scope, null, l_params);

    apex_debug.warn('HTTP %s %s id: %s', p_error_code, p_reason, coalesce(p_id, '(NULL)'));
    sys.owa_util.status_line(
      nstatus       => p_error_code,
      creason       => p_reason,
      bclose_header => true
    );
    apex_application.stop_apex_engine;
  
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END raise_http_error;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Global functions and procedures
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION init_session (
    p_app_id      IN NUMBER,
    p_session_id  IN NUMBER
  ) RETURN NUMBER
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'init_session';
    l_params logger.tab_param;
    l_user_id     NUMBER(38);
    l_user_name   VARCHAR2(255);
  BEGIN
    logger.append_param(l_params, 'p_app_id', p_app_id);
    logger.append_param(l_params, 'p_session_id', p_session_id);
    logger.log('START', l_scope, null, l_params);

    blog_util.set_items_from_param(p_app_id);
    l_user_id := blog_util.get_cookie;
    IF l_user_id IS NOT NULL THEN
      l_user_name := blog_util.get_user_name(l_user_id);
      IF l_user_name IS NOT NULL THEN
        /* Set APP_USER */
        apex_custom_auth.set_user(upper(l_user_name));
      ELSE
        l_user_id := NULL;
      END IF;
    END IF;
    IF apex_authorization.is_authorized('LOGGING_ENABLED') THEN
      blog_log.write_activity_log(
        p_user_id       => l_user_id,
        p_session_id    => p_session_id,
        p_ip_address    => sys.owa_util.get_cgi_env('REMOTE_ADDR'),
        p_user_agent    => sys.owa_util.get_cgi_env('HTTP_USER_AGENT'),
        p_referer       => sys.owa_util.get_cgi_env('HTTP_REFERER'),
        p_activity_type => 'NEW_SESSION'
      );
    END IF;

    logger.log('END', l_scope);
    RETURN l_user_id;
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END init_session;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_param_value(
    p_param_id IN VARCHAR2
  ) RETURN VARCHAR2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_param_value';
    l_params logger.tab_param;
    l_value VARCHAR2(4000);
  BEGIN
    logger.append_param(l_params, 'p_param_id', p_param_id);
    logger.log('START', l_scope, null, l_params);

    SELECT param_value
    INTO l_value
    FROM blog_param
    WHERE param_id = p_param_id
    ;
    logger.log('l_value :'||l_value, l_scope, null, l_params);
    logger.log('END', l_scope);
    RETURN l_value;
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END get_param_value;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE set_items_from_param(
    p_app_id IN NUMBER
  ) AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'set_items_from_param';
    l_params logger.tab_param;
  --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    logger.append_param(l_params, 'p_app_id', p_app_id);
    logger.log('START', l_scope, null, l_params);

    FOR c1 IN (
      SELECT
        p.param_id,
        p.param_value
      FROM blog_param p
      WHERE p.param_value IS NOT NULL
        AND EXISTS(
          SELECT 1
          FROM blog_param_app a
          WHERE a.application_id = p_app_id
          AND a.param_id = p.param_id
        )
    ) LOOP
      apex_util.set_session_state(c1.param_id, c1.param_value);
    END LOOP;
    logger.log('END', l_scope);
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END set_items_from_param;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_comment(
    p_user_id         IN OUT NOCOPY NUMBER,
    p_apex_session_id IN NUMBER,
    p_app_alias       IN VARCHAR2,
    p_base_url        IN VARCHAR2,
    p_blog_name       IN VARCHAR2,
    p_page_id         IN NUMBER,
    p_page_title      IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_nick_name       IN VARCHAR2,
    p_website         IN VARCHAR2,
    p_followup        IN VARCHAR2,
    p_comment         IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'save_comment';
    l_params logger.tab_param;
    l_article_url VARCHAR2(4000);
    l_comment_id  NUMBER(38);
    l_publish     VARCHAR2(1) := 'N';
    l_author      t_author;
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_apex_session_id', p_apex_session_id);
    logger.append_param(l_params, 'p_app_alias', p_app_alias);
    logger.append_param(l_params, 'p_base_url', p_base_url);
    logger.append_param(l_params, 'p_blog_name', p_blog_name);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_page_title', p_page_title);
    logger.append_param(l_params, 'p_email', p_email);
    logger.append_param(l_params, 'p_nick_name', p_nick_name);
    logger.append_param(l_params, 'p_website', p_website);
    logger.append_param(l_params, 'p_followup', p_followup);
    logger.append_param(l_params, 'p_comment', p_comment);
    logger.log('START', l_scope, null, l_params);

    /* Set APP_USER */
    apex_custom_auth.set_user(upper(p_nick_name));
    --
    /* Insert or update user */
    blog_util.save_user_attr(
      p_user_id     => p_user_id,
      p_email       => p_email,
      p_nick_name   => p_nick_name,
      p_website     => p_website
    );
    /* Save should user be notified when new comment is posted */
    
    blog_util.save_notify_user(
      p_user_id     => p_user_id,
      p_page_id     => p_page_id,
      p_followup    => p_followup
    );
    /* Set user id to cookie */
    blog_util.set_cookie(p_user_id);
    --
    /* Should author moderate comment before it is published */
    IF NOT apex_authorization.is_authorized('MODERATION_ENABLED') THEN
      logger.log('MODERATION_ENABLED not turned on.', l_scope, null, l_params);
      l_publish := 'Y';
    else
      logger.log('MODERATION_ENABLED turned on so it should not publish immediately.', l_scope, null, l_params);
    END IF;
    --
    /* Inser comment to table */
    INSERT INTO blog_comment
    (user_id, apex_session_id, page_id, comment_text, moderated)
    VALUES
    (p_user_id, p_apex_session_id, p_page_id, p_comment , l_publish)
    RETURNING comment_id INTO l_comment_id
    ;

    notify_blog_commenters (
          p_comment_id    => l_comment_id,
          p_page_id       => p_page_id
        ); --hhh : just testing. I should really figure out the below.
    --
    /* Update user id to activity log */
    UPDATE blog_activity_log
    SET user_id = p_user_id
    WHERE apex_session_id = p_apex_session_id
      AND user_id IS NULL
    ;
    --
    /* Send email about new comment to readers */
    IF apex_authorization.is_authorized('NOTIFICATION_EMAIL_ENABLED') THEN
      IF l_publish = 'Y' THEN
        logger.log('Moderation is not enabled so it immediately publishes the comment and notifies readers.', l_scope, null, l_params);
        
        notify_blog_commenters (
          p_comment_id    => l_comment_id,
          p_page_id       => p_page_id
        );
      ELSE 
        logger.log('Moderation is enabled so readers are not immediately notified.', l_scope, null, l_params);
      END IF;
    --
      /* Get author details for notification emails */
      l_author := blog_util.get_article_author(p_page_id);
      --
      /* Send email about new comment to author */
      /* If we have author email and author is active and like have notifications */
      IF  l_author.v_email IS NOT NULL AND l_author.v_email_notify = 'Y'
      THEN
        logger.log('Prepping to notify the blog author @ :'||l_author.v_email, l_scope, null, l_params);
        /* Get article url */
        l_article_url := blog_util.get_article_url(p_page_id, p_app_alias, p_base_url);
        --
        blog_util.notify_author (
          p_page_title    => p_page_title,
          p_article_url   => l_article_url,
          p_blog_name     => p_blog_name,
          p_author_name   => l_author.v_author_name,
          p_author_email  => l_author.v_email
        );
      else 
        logger.log('Settings prevent notifying the blog author @ :'||l_author.v_email, l_scope, null, l_params);
      END IF;
    END IF;
    /* Refresh comment log */
    dbms_mview.refresh('BLOG_COMMENT_LOG');
    logger.log('END', l_scope);
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END save_comment;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_contact(
    p_user_id         IN OUT NOCOPY NUMBER,
    p_apex_session_id IN NUMBER,
    p_email           IN VARCHAR2,
    p_nick_name       IN VARCHAR2,
    p_website         IN VARCHAR2,
    p_comment         IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'save_contact';
    l_params logger.tab_param;
  BEGIN
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_apex_session_id', p_apex_session_id);
    logger.append_param(l_params, 'p_email', p_email);
    logger.append_param(l_params, 'p_nick_name', p_nick_name);
    logger.append_param(l_params, 'p_website', p_website);
    logger.append_param(l_params, 'p_comment', p_comment);
    logger.log('START', l_scope, null, l_params);

    /* Set APP_USER */
    apex_custom_auth.set_user(upper(p_nick_name));
    /* Insert or update user */
    blog_util.save_user_attr(
      p_user_id     => p_user_id,
      p_email       => p_email,
      p_nick_name   => p_nick_name,
      p_website     => p_website
    );
    /* Inser message to table */
    INSERT INTO blog_contact_message
    (user_id, apex_session_id, message)
    VALUES
    (p_user_id, p_apex_session_id, p_comment)
    ;
     /* Set user id to cookie */
    blog_util.set_cookie(p_user_id);
    logger.log('END', l_scope);
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END save_contact;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

  PROCEDURE notify_blog_commenters (
    p_comment_id    IN NUMBER,
    p_page_id       IN NUMBER
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'notify_blog_commenters';
    l_params logger.tab_param;
    l_article_url     VARCHAR2(2000);
    l_unsubscribe_url VARCHAR2(2000);
    l_user_email      t_email;
    l_email           t_email;
    l_list_id         varchar2(50);
    l_post_name       varchar2(200);
    l_post_name_count integer;
    l_comment_count   integer;
    l_comment_txt     varchar2(2000);
    l_template_id     integer := 39405; --this is the template from mailchimp
    l_merge_id        integer;
    l_tag             varchar2(100);
    l_success0        boolean;
    l_success         boolean;
    l_success1        boolean;
    l_success2        boolean;
    l_campaign_id     varchar2(50);
    l_send_url        varchar2(1000);
  BEGIN
    logger.append_param(l_params, 'p_comment_id', p_comment_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.log('START', l_scope, null, l_params);

    begin
    select email_list_id
      into l_list_id
      from blog_posts
      where page_id  = p_page_id;
      logger.log('l_list_id :'||l_list_id, l_scope, null, l_params);
    exception when no_data_found then 
      logger.log_error('Missing data in blog posts table.', l_scope, null, l_params); 
      raise;
    end;

    begin
      select substr(comment_text,1,1000)
        into l_comment_txt
        from blog_comment
        where comment_id = p_comment_id;
      logger.log('l_comment_txt :'||substr(l_comment_txt,1,50), l_scope, null, l_params);
    exception when no_data_found then 
      logger.log_error('Missing data from the blog_comment table.', l_scope, null, l_params); 
      raise;
    end;

    begin
      select page_name
        into l_post_name
        from APEX_APPLICATION_PAGES
        where page_id = p_page_id
        and APPLICATION_NAME='Blog';
        logger.log('l_post_name :'||l_post_name, l_scope, null, l_params);
    exception when no_data_found then 
      logger.log_error('Missing data from the APEX_APPLICATION_PAGES table.', l_scope, null, l_params); 
      raise;
    end;

    select count(*)
      into l_post_name_count 
      from table(mailchimp_pkg.get_list_of_merge_fields(p_list_id => l_list_id))
      where tag = 'POST_NAME'
      order by merge_id;
    
    if l_post_name_count > 0 then
      logger.log('The POST_NAME tag is already created for this list.', l_scope, null, l_params);
    else 
      logger.log('The POST_NAME tag does not already exist for this list.', l_scope, null, l_params);
           mailchimp_pkg.create_merge_field(p_list_id          => l_list_id, ------------ the id of the list that would make use of this merge id
                                            p_merge_field_tag  => 'POST_NAME', ---------- the name you want to give the merge variable
                                            p_merge_field_name => 'The blog post name.',
                                            p_merge_id         => l_merge_id, ------------ out parameter
                                            p_tag              => l_tag); ---------------- out parameter
    end if;

         mailchimp_pkg.update_merge_field ( p_list_id         => l_list_id,
                                            p_merge_field_tag => 'POST_NAME',
                                            p_merge_value     => l_post_name,
                                            p_success         => l_success0);
    if l_success0 then
      logger.log('POST_NAME Merge field successfully updated.', l_scope, null, l_params);
    else 
      logger.log('POST_NAME Merge field not updated for unknown reason.', l_scope, null, l_params);
    end if;
    
    select count(*)
      into l_comment_count 
      from table(mailchimp_pkg.get_list_of_merge_fields(p_list_id => l_list_id))
      where tag = 'LATEST_COMMENT'
      order by merge_id;
    
    --if l_comment_count > 0 then
    --  logger.log('The l_comment_count tag is already created for this list.', l_scope, null, l_params);
    --else 
           mailchimp_pkg.create_merge_field(p_list_id          => l_list_id, --- the id of the list that would make use of this merge id
                                            p_merge_field_tag  => 'COMMENT', --- the name you want to give the merge variable
                                            p_merge_field_name => 'Latest blog post comment.',
                                            p_merge_id         => l_merge_id,
                                            p_tag              => l_tag);
    --end if;

         mailchimp_pkg.update_merge_field ( p_list_id         => l_list_id,
                                            p_merge_field_tag => 'COMMENT',
                                            p_merge_value     => l_comment_txt,
                                            p_success         => l_success);
    
    if l_success then
      logger.log('LATEST_COMMENT Merge field successfully updated.', l_scope, null, l_params);
    else 
      logger.log('LATEST_COMMENT Merge field not updated for unknown reason.', l_scope, null, l_params);
    end if;
    
         mailchimp_pkg.create_merge_field(  p_list_id          => l_list_id, --- the id of the list that would make use of this merge id
                                            p_merge_field_tag  => 'BLOGLINK', --- the name you want to give the merge variable
                                            p_merge_field_name => 'Link to blog.',
                                            p_merge_id         => l_merge_id,
                                            p_tag              => l_tag);
    --end if;

         mailchimp_pkg.update_merge_field ( p_list_id         => l_list_id,
                                            p_merge_field_tag => 'BLOGLINK',
                                            p_merge_value     => 'https://2122.io/apex/f?p=427:'||p_page_id,
                                            p_success         => l_success1);
                                  
    if l_success1 then
      logger.log('BLOGLINK Merge field successfully updated.', l_scope, null, l_params);
    else 
      logger.log('BLOGLINK Merge field not updated for unknown reason.', l_scope, null, l_params);
    end if;

         mailchimp_pkg.create_campaign (  p_list_id      => l_list_id,
                                          p_subject_line => 'New comment on blog post',
                                          p_title        => 'New comment',
                                          p_template_id  => l_template_id,
                                          p_campaign_id  => l_campaign_id,
                                          p_send_url     => l_send_url);

         mailchimp_pkg.send_campaign (p_send_url => l_send_url,
                                      p_success  => l_success2);

    
    
    if l_success2 then
      logger.log('Email sent.', l_scope, null, l_params);
    else 
      logger.log('Email not sent for unknown reason.', l_scope, null, l_params);
    end if; ---hhh : apparently this is the wrong spot

    UPDATE blog_comment
      SET notify_email_sent = 'Y'
    WHERE comment_id = p_comment_id
      AND active = 'Y'
      AND moderated = 'Y'
      AND notify_email_sent = 'N'
    ;
    
    logger.log('END', l_scope);
  
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END notify_blog_commenters;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE unsubscribe(
    p_value       IN OUT NOCOPY VARCHAR2,
    p_user_id     OUT NOCOPY NUMBER,
    p_page_id  OUT NOCOPY NUMBER
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'unsubscribe';
    l_params logger.tab_param;
    l_user_name VARCHAR2(255);
    l_arr       apex_application_global.vc_arr2;
  BEGIN
    logger.append_param(l_params, 'p_value', p_value);
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.log('START', l_scope, null, l_params);

    l_arr         := blog_util.raw_to_table(p_value);
    p_value       := NULL;
    p_user_id     := l_arr(1);
    p_page_id  := l_arr(2);
    IF p_user_id IS NOT NULL THEN
      l_user_name := blog_util.get_user_name(p_user_id);
    END IF;
    IF p_user_id IS NOT NULL
    AND l_user_name IS NOT NULL
    AND p_page_id IS NOT NULL
    THEN
      /* Set APP_USER */
      apex_custom_auth.set_user(upper(l_user_name));
      blog_util.save_notify_user(
        p_user_id    => p_user_id,
        p_page_id => p_page_id,
        p_followup   => 'N'
      );
    ELSE
      blog_util.raise_http_error(p_value);
    END IF;
    logger.log('END', l_scope);

  EXCEPTION WHEN
    NO_DATA_FOUND OR
    INVALID_NUMBER OR
    VALUE_ERROR
  THEN
    blog_util.raise_http_error(p_value);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params);
 when others then 
  logger.log_error('Unhandled Exception', l_scope, null, l_params); 
  raise;
  END unsubscribe;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
 
  FUNCTION validate_email(
    p_email     IN VARCHAR2
  ) RETURN BOOLEAN
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'validate_email';
    l_params logger.tab_param;
    l_is_valid    BOOLEAN := TRUE;
    l_dot_pos     SIMPLE_INTEGER := 0;
    l_at_pos      SIMPLE_INTEGER := 0;
    l_str_length  SIMPLE_INTEGER := 0;
  BEGIN
    logger.append_param(l_params, 'p_email', p_email);
    logger.log('START', l_scope, null, l_params);

    IF p_email IS NOT NULL THEN
      l_dot_pos     := instr(p_email ,'.');
      l_at_pos      := instr(p_email ,'@');
      l_str_length  := LENGTH(p_email);
      IF (
        (l_dot_pos = 0)
        OR (l_at_pos = 0)
        --OR (l_dot_pos = l_at_pos - 1)
        OR (l_dot_pos = l_at_pos + 1)
        OR (l_at_pos = 1)
        OR (l_at_pos = l_str_length)
        OR (l_dot_pos = l_str_length)
        OR (l_str_length > 256)
      )
      THEN
        l_is_valid := FALSE;
      END IF;
      IF l_is_valid THEN
        l_is_valid := NOT instr(substr(p_email ,l_at_pos) ,'.') = 0;
      END IF;
    END IF;

    logger.log('END', l_scope);
    RETURN l_is_valid;

  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END validate_email;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  
END "BLOG_UTIL";
/