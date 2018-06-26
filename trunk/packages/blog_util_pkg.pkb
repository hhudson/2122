create or replace PACKAGE BODY  "BLOG_UTIL" 
AS
--------------------------------------------------------------------------------
--the below is part of logger best practices
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

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
      l_email.v_subj := regexp_replace( l_email.v_subj, l_key, l_arr(l_key), 1, 0, 'i' );
      l_email.v_body := regexp_replace( l_email.v_body, l_key, l_arr(l_key), 1, 0, 'i' );
      l_key := l_arr.NEXT(l_key);
    END LOOP;
    /* Get blog email */
    l_email.v_from := blog_util.get_param_value('BLOG_EMAIL');
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
    l_scope logger_logs.scope%type := gc_scope_prefix || 'save_notify_user';
    l_params logger.tab_param;
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
    l_email := blog_util.get_email_message(
      p_page_title => p_page_title,
      p_article_url   => p_article_url,
      p_blog_name     => p_blog_name,
      p_author_name   => p_author_name,
      p_subj          => 'NEW_COMMENT_EMAIL_SUBJ',
      p_body          => 'NEW_COMMENT_EMAIL_BODY'
    );
    /* Send mail to author */
    apex_mail.send (
      p_from => l_email.v_from,
      p_to   => p_author_email,
      p_subj => l_email.v_subj,
      p_body => l_email.v_body
    );
    /* we do have time wait email sending */
    --APEX_MAIL.PUSH_QUEUE;
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
  PROCEDURE check_http410(
    p_id  IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'check_http410';
    l_params logger.tab_param;
    l_count PLS_INTEGER;
  BEGIN
    logger.append_param(l_params, 'p_id', p_id);
    logger.log('START', l_scope, null, l_params);

    SELECT COUNT(1)
    INTO l_count
    FROM blog_http410 c
    WHERE c.deleted_id = p_id
    ;

    logger.log('END', l_scope);
    blog_util.raise_http_error(p_id, 410, 'Gone');
  EXCEPTION WHEN 
    NO_DATA_FOUND
  THEN
    blog_util.raise_http_error(p_id);
    logger.log_error('No data found', l_scope, null, l_params); 
  when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END check_http410;
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
      l_publish := 'Y';
    END IF;
    --
    /* Inser comment to table */
    INSERT INTO blog_comment
    (user_id, apex_session_id, page_id, comment_text, moderated)
    VALUES
    (p_user_id, p_apex_session_id, p_page_id, p_comment , l_publish)
    RETURNING comment_id INTO l_comment_id
    ;
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
        blog_util.notify_readers (
          p_comment_id    => l_comment_id,
          p_user_id       => p_user_id,
          p_page_id       => p_page_id,
          p_page_title    => p_page_title,
          p_app_alias     => p_app_alias,
          p_base_url      => p_base_url,
          p_blog_name     => p_blog_name
        );
      END IF;
    --
      /* Get author details for notification emails */
      l_author := blog_util.get_article_author(p_page_id);
      --
      /* Send email about new comment to author */
      /* If we have author email and author is active and like have notifications */
      IF  l_author.v_email IS NOT NULL AND l_author.v_email_notify = 'Y'
      THEN
        /* Get article url */
        l_article_url := blog_util.get_article_url(p_page_id, p_app_alias, p_base_url);
        --
        blog_util.notify_author (
          p_page_title => p_page_title,
          p_article_url   => l_article_url,
          p_blog_name     => p_blog_name,
          p_author_name   => l_author.v_author_name,
          p_author_email  => l_author.v_email
        );
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
  PROCEDURE notify_readers (
    p_comment_id    IN NUMBER,
    p_user_id       IN NUMBER,
    p_page_id       IN NUMBER,
    p_page_title    IN VARCHAR2,
    p_app_alias     IN VARCHAR2,
    p_base_url      IN VARCHAR2,
    p_blog_name     IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'notify_readers';
    l_params logger.tab_param;
    l_article_url     VARCHAR2(2000);
    l_unsubscribe_url VARCHAR2(2000);
    l_user_email      t_email;
    l_email           t_email;
  BEGIN
    logger.append_param(l_params, 'p_comment_id', p_comment_id);
    logger.append_param(l_params, 'p_user_id', p_user_id);
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.append_param(l_params, 'p_page_title', p_page_title);
    logger.append_param(l_params, 'p_app_alias', p_app_alias);
    logger.append_param(l_params, 'p_base_url', p_base_url);
    logger.append_param(l_params, 'p_blog_name', p_blog_name);
    logger.log('START', l_scope, null, l_params);

    /* Get article url */
    l_article_url := blog_util.get_article_url(p_page_id, p_app_alias, p_base_url);
    /* Get email subject and body to variables */
    l_email := blog_util.get_email_message(
      p_page_title => p_page_title,
      p_article_url   => l_article_url,
      p_blog_name     => p_blog_name,
      p_author_name   => '#AUTHOR_NAME#',
      p_subj          => 'FOLLOWUP_EMAIL_SUBJ',
      p_body          => 'FOLLOWUP_EMAIL_BODY'
    );
    /* Loop trough all users that like have notification */
    FOR c1 IN (
      SELECT email,
        nick_name,
        user_id
      FROM blog_comment_user u
      WHERE u.user_id != p_user_id
        AND u.blocked = 'N'
        AND EXISTS(
          SELECT 1
          FROM blog_comment_notify n
          WHERE n.user_id = u.user_id
          AND n.page_id = p_page_id
          AND n.followup_notify = 'Y'
          AND n.changed_on > g_watche_expires
        )
        AND EXISTS(
          SELECT 1
          FROM blog_comment c
          WHERE c.page_id = p_page_id
          AND c.comment_id = p_comment_id
          AND c.active = 'Y'
          AND c.moderated = 'Y'
          AND c.notify_email_sent = 'N'
        )
    ) LOOP
      /* User specific unsubscribe url */
      l_unsubscribe_url := blog_util.get_unsubscribe_url(
        p_user_id     => c1.user_id,
        p_page_id  => p_page_id,
        p_app_alias   => p_app_alias,
        p_base_url    => p_base_url
      );
      /* Make user specific substitutions */
      l_user_email.v_subj := regexp_replace(l_email.v_subj, '#NICK_NAME#', c1.nick_name, 1, 0, 'i');
      l_user_email.v_body := regexp_replace(l_email.v_body, '#NICK_NAME#', c1.nick_name, 1, 0, 'i');
      l_user_email.v_body := regexp_replace(l_user_email.v_body, '#UNSUBSCRIBE_URL#', l_unsubscribe_url, 1, 0, 'i');
      /* Send mail to user */
      apex_mail.send (
        p_from => l_email.v_from,
        p_to   => c1.email,
        p_subj => l_user_email.v_subj,
        p_body => l_user_email.v_body
      );
    END LOOP;
    /* we do have time wait email sending */
    --APEX_MAIL.PUSH_QUEUE;
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
  END notify_readers;
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
  PROCEDURE download_file (
    p_file_name   IN VARCHAR2,
    p_session_id  IN NUMBER,
    p_user_id     IN VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'download_file';
    l_params logger.tab_param;
    l_file_name       VARCHAR2(2000);
    l_utc             TIMESTAMP;
    l_file_cached     BOOLEAN;
    l_file_rowtype    blog_file%ROWTYPE;
    l_arr             apex_application_global.vc_arr2;
    c_date_lang       CONSTANT VARCHAR2(255) := 'NLS_DATE_LANGUAGE=ENGLISH';
    c_date_format     CONSTANT VARCHAR2(255) := 'Dy, DD Mon YYYY HH24:MI:SS "GMT"';
    --SESSION_NOT_VALID EXCEPTION;
    FILE_NOT_ACTIVE   EXCEPTION;
    --PRAGMA EXCEPTION_INIT(SESSION_NOT_VALID, -20001);
    PRAGMA EXCEPTION_INIT(FILE_NOT_ACTIVE, -20002);
  BEGIN
    logger.append_param(l_params, 'p_file_name', p_file_name);
    logger.log('START', l_scope, null, l_params);
    /*
    IF NOT apex_custom_auth.is_session_valid THEN
      apex_debug.warn('File download session is not valid: %s', p_session_id);
      raise_application_error(-20001, 'Unauthorized access - file will not be retrieved.');
    END IF;
    */
	
	sys.htp.flush;
	sys.htp.init;
	
    l_file_cached := FALSE;
    l_arr := apex_util.string_to_table(p_file_name, '?');
    l_file_name := l_arr(1);
    l_utc := SYS_EXTRACT_UTC(SYSTIMESTAMP);
    SELECT *
    INTO l_file_rowtype
    FROM blog_file
    WHERE file_name = l_file_name
    ;
    IF NOT l_file_rowtype.active = 'Y' THEN
      raise_application_error(-20002, 'File is not available for download.');
    END IF;
    sys.owa_util.mime_header(COALESCE (l_file_rowtype.mime_type, 'application/octet'), FALSE);
    IF l_file_rowtype.file_type != 'FILE' THEN
      /* File type is not FILE, then use cache e.g. for images, css and JavaScript */
      /* Cache and ETag headers */
      sys.htp.p('Cache-Control: public, max-age=31536000');
      sys.htp.p('Date: '    || to_char(l_utc, c_date_format, c_date_lang));
      sys.htp.p('Expires: ' || to_char(l_utc + 365, c_date_format, c_date_lang));
      sys.htp.p('ETag: "'   || l_file_rowtype.file_etag || '"');
      /* Check if file is modified after last download */
      IF sys.owa_util.get_cgi_env('HTTP_IF_MODIFIED_SINCE') = l_file_rowtype.file_modified_since
      OR sys.owa_util.get_cgi_env('HTTP_IF_NONE_MATCH')  = l_file_rowtype.file_etag
      THEN
        sys.owa_util.status_line(
          nstatus       => 304,
          creason       => 'Not Modified',
          bclose_header => FALSE
        );
        l_file_cached := TRUE;
      ELSE
        sys.htp.p('Last-Modified : ' || l_file_rowtype.file_modified_since);
      END IF;
    ELSE
      IF apex_authorization.is_authorized('LOGGING_ENABLED') THEN
        /* Log file download */
        blog_log.write_file_log(l_file_rowtype.file_id);
        blog_log.write_activity_log(
          p_user_id       => p_user_id,
          p_session_id    => p_session_id,
          p_activity_type => 'DOWNLOAD',
          p_related_id    => l_file_rowtype.file_id
        );
      END IF;
      sys.htp.p('Content-Disposition: attachment; filename="' || l_file_rowtype.file_name || '"');
    END IF;
    IF NOT l_file_cached THEN
      sys.htp.p('Content-length: ' || l_file_rowtype.file_size);
      sys.wpg_docload.download_file(l_file_rowtype.blob_content);
    END IF;
    sys.owa_util.http_header_close;
    apex_application.stop_apex_engine;
    logger.log('END', l_scope);

  EXCEPTION WHEN 
    NO_DATA_FOUND
  THEN
    check_http410(l_file_name);
  WHEN
    VALUE_ERROR OR
    INVALID_NUMBER OR
    FILE_NOT_ACTIVE
  THEN
    blog_util.raise_http_error(l_file_name);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params);
  when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    raise;
  END download_file;
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
  /*PROCEDURE get_article_page_items (
    p_page_id      IN VARCHAR2,
    p_page_title      OUT NOCOPY VARCHAR2,
    p_region_title    OUT NOCOPY VARCHAR2,
    p_keywords        OUT NOCOPY VARCHAR2,
    p_description     OUT NOCOPY VARCHAR2,
    p_author_name     OUT NOCOPY VARCHAR2,
    p_twitter_follow  OUT NOCOPY VARCHAR2,
    p_rate            OUT NOCOPY NUMBER    
  ) 
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_article_page_items';
    l_params logger.tab_param;
    l_page_id    NUMBER;
    l_category_name VARCHAR2(256);
  BEGIN
    logger.append_param(l_params, 'p_page_id', p_page_id);
    logger.log('START', l_scope, null, l_params);
    --Input parameter p_category_id is string because we handle invalid number exception 
    l_page_id := to_number(p_page_id);
    SELECT a.article_title,
      a.category_name,
      a.keywords,
      a.description,
      a.author_name,
      a.author_twitter,
      l.article_rate_int
    INTO p_page_title,
      l_category_name,
      p_keywords,
      p_description,
      p_author_name,
      p_twitter_follow,
      p_rate
    FROM blog_v$article a
    LEFT JOIN blog_article_log l
    ON a.page_id = l.page_id
    WHERE a.page_id = l_page_id
    ;
    p_region_title  := apex_lang.message('REGION_TITLE_COMMENTS');
    p_keywords      := ltrim(trim(BOTH ',' FROM p_keywords) || ',' || l_category_name, ',');
    p_rate          := coalesce(p_rate, 0);
    logger.log('END', l_scope);

  EXCEPTION WHEN 
    NO_DATA_FOUND
  THEN
    check_http410(p_page_id);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params); 
  WHEN
    INVALID_NUMBER OR
    VALUE_ERROR
  THEN
    blog_util.raise_http_error(p_page_id);
    logger.log_error('Exception :'||sqlerrm, l_scope, null, l_params); 
 when others then 
  logger.log_error('Unhandled Exception', l_scope, null, l_params); 
  raise;
  END get_article_page_items;*/
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE get_category_page_items (
    p_category_id   IN VARCHAR2,
    p_page_title    OUT NOCOPY VARCHAR2,
    p_region_title  OUT NOCOPY VARCHAR2,
    p_category_name OUT NOCOPY VARCHAR2
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'get_category_page_items';
    l_params logger.tab_param;
    l_category_id NUMBER;
  BEGIN
    logger.append_param(l_params, 'p_category_id', p_category_id);
    logger.log('START', l_scope, null, l_params);
    /* Input parameter p_category_id is string because we handle invalid number exception */
    l_category_id := to_number(p_category_id);
    SELECT c.category_name
    INTO p_category_name
    FROM blog_category c
    WHERE c.category_id = l_category_id
    ;
    p_page_title    := apex_lang.message('PAGE_TITLE_CATEGORY', p_category_name);
    p_region_title  := apex_lang.message('REGION_TITLE_CATEGORY', apex_escape.html(p_category_name));
    p_category_name := p_category_name;
    logger.log('END', l_scope);

  EXCEPTION WHEN 
    NO_DATA_FOUND
  THEN
    check_http410(p_category_id);
  WHEN
    INVALID_NUMBER OR
    VALUE_ERROR
  THEN
    blog_util.raise_http_error(p_category_id);
  when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
    raise;
  END get_category_page_items;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_UTIL";
/