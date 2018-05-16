create or replace PACKAGE BODY  "BLOG_LOG" 
AS
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  INSERT_NULL_VALUE EXCEPTION;
  PARENT_NOT_FOUND  EXCEPTION;
  PRAGMA EXCEPTION_INIT(INSERT_NULL_VALUE, -1400);
  PRAGMA EXCEPTION_INIT(PARENT_NOT_FOUND, -2291);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION apex_error_handler(
    p_error IN apex_error.t_error
  ) RETURN apex_error.t_error_result
  AS
    l_result          apex_error.t_error_result;
    l_error           apex_error.t_error;
    l_reference_id    PLS_INTEGER;
    l_constraint_name VARCHAR2(255);
    l_err_msg         VARCHAR2(32700);
  BEGIN
    l_result := apex_error.init_error_result ( p_error => p_error );
    -- If it's an internal error raised by APEX, like an invalid statement or
    -- code which can't be executed, the error text might contain security sensitive
    -- information. To avoid this security problem we can rewrite the error to
    -- a generic error message and log the original error message for further
    -- investigation by the help desk.
    IF p_error.is_internal_error THEN
      -- Access Denied errors raised by application or page authorization should
      -- still show up with the original error message
      IF NOT p_error.apex_error_code LIKE 'APEX.SESSION_STATE.%'
      AND NOT p_error.apex_error_code = 'APEX.AUTHORIZATION.ACCESS_DENIED'
      AND NOT p_error.apex_error_code = 'APEX.PAGE.DUPLICATE_SUBMIT'
      AND NOT p_error.apex_error_code = 'APEX.SESSION_STATE.RESTRICTED_CHAR.WEB_SAFE'
      AND NOT p_error.apex_error_code = 'APEX.SESSION_STATE.RESTRICTED_CHAR.US_ONLY'
      THEN
        -- log error for example with an autonomous transaction and return
        -- l_reference_id as reference#
        -- l_reference_id := log_error (
        --                       p_error => p_error );
        --
        -- Change the message to the generic error message which doesn't expose
        -- any sensitive information.
        -- log error to application debug information
        apex_debug.error(
          'Error handler: %s %s %s',
           p_error.apex_error_code,
           l_result.message,
           l_result.additional_info
        );
        l_result.message := apex_lang.message('GENERAL_ERROR');
        l_result.additional_info := NULL;
      END IF;
    ELSE
      /*
      -- Show the error as inline error
      l_result.display_location :=
      CASE
      WHEN l_result.display_location = apex_error.c_on_error_page THEN
        apex_error.c_inline_in_notification
      ELSE
        l_result.display_location
      END;
      */
      -- If it's a constraint violation like
      --
      --   -) ORA-02292ORA-02291ORA-02290ORA-02091ORA-00001: unique constraint violated
      --   -) : transaction rolled back (-> can hide a deferred constraint)
      --   -) : check constraint violated
      --   -) : integrity constraint violated - parent key not found
      --   -) : integrity constraint violated - child record found
      --
      -- we try to get a friendly error message from our constraint lookup configuration.
      -- If we don't find the constraint in our lookup table we fallback to
      -- the original ORA error message.
      IF p_error.ora_sqlcode IN (-1, -2091, -2290, -2291, -2292) THEN
        l_constraint_name := apex_error.extract_constraint_name ( p_error => p_error );
        l_err_msg := apex_lang.message(l_constraint_name);
        -- not every constraint has to be in our lookup table
        IF NOT l_err_msg = l_constraint_name THEN
          l_result.message := l_err_msg;
        END IF;
      END IF;
      -- If an ORA error has been raised, for example a raise_application_error(-20xxx, '...')
      -- in a table trigger or in a PL/SQL package called by a process and we
      -- haven't found the error in our lookup table, then we just want to see
      -- the actual error text and not the full error stack with all the ORA error numbers.
      IF p_error.ora_sqlcode IS NOT NULL AND l_result.message = p_error.message THEN
        l_result.message := apex_error.get_first_ora_error_text ( p_error => p_error );
      END IF;
      -- If no associated page item/tabular form column has been set, we can use
      -- apex_error.auto_set_associated_item to automatically guess the affected
      -- error field by examine the ORA error for constraint names or column names.
      IF l_result.page_item_name IS NULL AND l_result.column_alias IS NULL THEN
        apex_error.auto_set_associated_item ( p_error => p_error, p_error_result => l_result );
      END IF;
    END IF;
    RETURN l_result;
  END apex_error_handler;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE write_activity_log(
    p_user_id         IN NUMBER,
    p_activity_type   IN VARCHAR2,
    p_session_id      IN NUMBER,
    p_related_id      IN NUMBER DEFAULT 0,
    p_ip_address      IN VARCHAR2 DEFAULT NULL,
    p_user_agent      IN VARCHAR2 DEFAULT NULL,
    p_referer         IN VARCHAR2 DEFAULT NULL,
    p_search_type     IN VARCHAR2 DEFAULT NULL,
    p_search          IN VARCHAR2 DEFAULT NULL,
    p_country_code    IN VARCHAR2 DEFAULT NULL,
    p_region          IN VARCHAR2 DEFAULT NULL,
    p_city            IN VARCHAR2 DEFAULT NULL,
    p_latitude        IN NUMBER DEFAULT NULL,
    p_longitude       IN NUMBER DEFAULT NULL,
    p_additional_info IN VARCHAR2 DEFAULT NULL
  )
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT /*+ append */ INTO blog_activity_log (
      ACTIVITY_TYPE,
      APEX_SESSION_ID,
      IP_ADDRESS,
      RELATED_ID,
      USER_ID,
      LATITUDE,
      LONGITUDE,
      COUNTRY_CODE,
      COUNTRY_REGION,
      COUNTRY_CITY,
      HTTP_USER_AGENT,
      HTTP_REFERER,
      SEARCH_TYPE,
      SEARCH_CRITERIA,
      ADDITIONAL_INFO
    ) VALUES (
      p_activity_type,
      p_session_id,
      p_ip_address,
      p_related_id,
      p_user_id,
      p_latitude,
      p_longitude,
      p_country_code,
      p_region,
      p_city,
      p_user_agent,
      p_referer,
      p_search_type,
      p_search,
      p_additional_info
    );
    COMMIT;
  END write_activity_log;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE write_article_log(
    p_article_id  IN NUMBER
  )
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE blog_article_log
    SET view_count = view_count + 1,
        last_view = SYSDATE
    WHERE article_id = p_article_id
    ;
    COMMIT;
  EXCEPTION WHEN 
  VALUE_ERROR OR
  INVALID_NUMBER OR
  PARENT_NOT_FOUND OR
  INSERT_NULL_VALUE
  THEN
      apex_debug.warn('blog_log.write_article_log(p_article_id => %s); error: %s', COALESCE(to_char(p_article_id), 'NULL'), sqlerrm);
  END write_article_log;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE rate_article(
    p_article_id    IN NUMBER,
    p_article_rate  IN OUT NOCOPY NUMBER
  )
  AS
    l_rate NUMBER;
  BEGIN
    UPDATE blog_article_log
      SET article_rate      = (article_rate * rate_click + p_article_rate) / (rate_click + 1),
          article_rate_int  = ROUND( (article_rate * rate_click + p_article_rate) / (rate_click + 1) ),
          rate_click        = rate_click + 1,
          last_rate         = SYSDATE
    WHERE article_id = p_article_id
    RETURNING article_rate_int INTO l_rate
    ;
    sys.htp.prn(l_rate);
  END rate_article;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE write_category_log(
    p_category_id  IN NUMBER
  )
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    MERGE INTO blog_category_log a
    USING (SELECT p_category_id AS category_id FROM DUAL) b
    ON (a.category_id = b.category_id)
    WHEN MATCHED THEN
    UPDATE SET a.view_count = a.view_count + 1,
      a.last_view = SYSDATE
    WHEN NOT MATCHED THEN
    INSERT (category_id) VALUES (b.category_id)
    ;
    COMMIT;
  EXCEPTION WHEN
    VALUE_ERROR OR
    INVALID_NUMBER OR
    PARENT_NOT_FOUND OR
    INSERT_NULL_VALUE
  THEN
    apex_debug.warn('blog_log.write_category_log(p_category_id => %s); error: %s', COALESCE(to_char(p_category_id), 'NULL'), sqlerrm);
  END write_category_log;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE write_file_log(
    p_file_id  IN NUMBER
  )
  AS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    MERGE INTO blog_file_log a
    USING (SELECT p_file_id AS file_id FROM DUAL) b
    ON (a.file_id = b.file_id)
    WHEN MATCHED THEN
    UPDATE SET a.click_count = a.click_count + 1,
      last_click = SYSDATE
    WHEN NOT MATCHED THEN
    INSERT (file_id) VALUES (b.file_id)
    ;
    COMMIT;
  EXCEPTION WHEN
  VALUE_ERROR OR
  INVALID_NUMBER OR
  PARENT_NOT_FOUND OR
  INSERT_NULL_VALUE
  THEN
    apex_debug.warn('blog_log.write_file_log(p_file_id => %s); error: %s', COALESCE(to_char(p_file_id), 'NULL'), sqlerrm);
  END write_file_log;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_LOG";
/