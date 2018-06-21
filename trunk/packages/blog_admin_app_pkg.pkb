create or replace PACKAGE BODY  "BLOG_ADMIN_APP" 
AS

gc_scope_prefix constant varchar2(31) := lower($plsql_unit) || '.';

--------------------------------------------------------------------------------
  -- Private constants and functions
  g_article_text_collection CONSTANT VARCHAR2(80) := 'ARTICLE_TEXT_COLLECTION';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION build_apex_lang_message_md5 (
    p_translation_entry_id  IN NUMBER,
    p_translatable_message  IN VARCHAR2,
    p_language_code         IN VARCHAR2,
    p_message_text          IN VARCHAR2,
    p_col_sep   IN VARCHAR2 DEFAULT '|'
  ) RETURN VARCHAR2
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'build_apex_lang_message_md5';
    l_params logger.tab_param;
  BEGIN
    logger.append_param(l_params, 'p_translation_entry_id', p_translation_entry_id);
    logger.append_param(l_params, 'p_translatable_message', p_translatable_message);
    logger.append_param(l_params, 'p_language_code', p_language_code);
    logger.append_param(l_params, 'p_message_text', p_message_text);
    logger.append_param(l_params, 'p_col_sep', p_col_sep);
    logger.log('START', l_scope, null, l_params);
    RETURN sys.utl_raw.cast_to_raw(sys.dbms_obfuscation_toolkit.md5(input_string => 
      p_translation_entry_id || p_col_sep ||
      p_translatable_message || p_col_sep ||
      p_language_code || p_col_sep ||
      p_message_text || p_col_sep ||
      ''
    ));
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope, null, l_params); 
  raise;
  END build_apex_lang_message_md5;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  -- Global procedures and functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE refresh_article_mview
  AS
  BEGIN
    dbms_mview.refresh('BLOG_ARCHIVE_LOV,BLOG_ARTICLE_HIT20,BLOG_ARTICLE_LAST20,BLOG_ARTICLE_TOP20','CCCC');
  END refresh_article_mview;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION table_to_clob (
    p_table IN APEX_APPLICATION_GLOBAL.VC_ARR2
  ) RETURN CLOB
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'table_to_clob';
    l_len   SIMPLE_INTEGER := 0;
    l_data  CLOB;
  BEGIN
    logger.log('START', l_scope);
    l_len := p_table.COUNT;
    IF l_len = 0
    OR COALESCE(LENGTH(p_table(1)), 0) = 0
    THEN
      RETURN EMPTY_CLOB();
    END IF;
    dbms_lob.createtemporary(
      lob_loc => l_data,
      cache   => TRUE,
      dur     => dbms_lob.session
    );
    dbms_lob.open(l_data, dbms_lob.lob_readwrite);
    FOR i IN 1 .. l_len
    LOOP
      dbms_lob.writeappend(
        lob_loc => l_data,
        amount  => LENGTH(p_table(i)),
        buffer  => p_table(i)
      );
    END LOOP;
    dbms_lob.close(l_data);
    logger.log('END', l_scope);
    RETURN l_data;
    exception when others then 
      logger.log_error('Unhandled Exception', l_scope); 
    raise;
  END table_to_clob;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE print_clob(
    p_clob IN CLOB
  )
  AS
    l_scope logger_logs.scope%type := gc_scope_prefix || 'print_clob';
    l_params logger.tab_param;
    l_length      SIMPLE_INTEGER := 0;
    l_clob_len    SIMPLE_INTEGER := 0;
    l_offset      SIMPLE_INTEGER := 1;
    l_byte_len    SIMPLE_INTEGER := 0;
    l_temp        VARCHAR2(32767);
  BEGIN
    logger.log('START', l_scope);
    l_length    := COALESCE(dbms_lob.getlength(p_clob), 0);
    l_clob_len  := l_length;
    l_byte_len  := 30000;
    --
    IF l_length < l_byte_len THEN
      sys.htp.prn(p_clob);
    ELSE
    --
      WHILE l_offset < l_length AND l_byte_len > 0
      LOOP
        /* Get 30k cut */
        l_temp := sys.dbms_lob.substr(p_clob,l_byte_len,l_offset);
        --
        /* Print HTML */
        sys.htp.prn(l_temp);
        --
        /* set the start position for the next cut */
        l_offset := l_offset + l_byte_len;
        --
        /* set the end position if less than 32k */
        l_clob_len := l_clob_len - l_byte_len;
        IF l_clob_len < l_byte_len THEN
          l_byte_len := l_clob_len;
        END IF;
      END LOOP;
    --
    END IF;
  logger.log('END', l_scope);
  exception when others then 
    logger.log_error('Unhandled Exception', l_scope); 
    raise;
  END print_clob;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_collection_name RETURN VARCHAR2
  AS
  BEGIN
    RETURN g_article_text_collection;
  END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE print_article_from_collection
  AS
    l_clob CLOB;
  BEGIN
    SELECT clob001
    INTO l_clob
    FROM apex_collections
    WHERE collection_name = g_article_text_collection
    AND seq_id = 1
    ;
    print_clob(l_clob);
  END print_article_from_collection ;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE table_to_collection (
    p_table IN APEX_APPLICATION_GLOBAL.VC_ARR2
  )
  AS
  BEGIN
    apex_collection.create_or_truncate_collection(g_article_text_collection);
    apex_collection.add_member(
      p_collection_name => g_article_text_collection,
      p_clob001         => table_to_clob(p_table)
    );
  END table_to_collection;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE article_to_collection (
    p_article_id IN NUMBER
  )
  AS
    l_clob CLOB;
  BEGIN
    apex_collection.create_or_truncate_collection(g_article_text_collection);
    BEGIN
      SELECT article_text
      INTO l_clob
      FROM blog_article
      WHERE article_id = p_article_id
      ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      l_clob := NULL;
    END;
    apex_collection.add_member(
      p_collection_name => g_article_text_collection,
      p_clob001 => l_clob
    );
  END article_to_collection;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_article_text (
    p_article_id      IN NUMBER,
    p_success_message IN OUT NOCOPY VARCHAR2,
    p_message         IN VARCHAR DEFAULT 'Action Processed.'
  )
  AS
  BEGIN
    MERGE INTO blog_article a
    USING (
      SELECT p_article_id AS article_id,
        clob001
      FROM apex_collections
      WHERE collection_name = g_article_text_collection
        AND seq_id  = 1
    ) b
    ON (a.article_id = b.article_id)
    WHEN MATCHED THEN
    UPDATE SET a.article_text = b.clob001
    WHERE sys.dbms_lob.compare(a.article_text, b.clob001) != 0
      OR sys.dbms_lob.compare(a.article_text, b.clob001) IS NULL
    ;
    IF SQL%ROWCOUNT > 0 THEN
      p_success_message := COALESCE(p_success_message, p_message);
    END IF;
  END save_article_text;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE save_article_preview (
    p_article_id      IN NUMBER,
    p_author_id       IN NUMBER,
    p_category_id     IN NUMBER,
    p_article_title   IN VARCHAR2,
    p_article_text    IN APEX_APPLICATION_GLOBAL.VC_ARR2
  )
  AS
  BEGIN
    /* Hopefully we can someday share collections between applications */
    blog_admin_app.table_to_collection (p_article_text);
    MERGE INTO blog_article_preview a
    USING (
      SELECT p_article_id AS article_id,
        p_author_id       AS author_id,
        p_category_id     AS category_id,
        p_article_title   AS article_title,
        clob001           AS article_text
      FROM apex_collections
      WHERE collection_name = g_article_text_collection
        AND seq_id  = 1
    ) b
    ON (a.apex_session_id = b.article_id)
    WHEN MATCHED THEN
    UPDATE SET a.article_text = b.article_text,
      a.author_id             = b.author_id,
      a.category_id           = b.category_id,
      a.article_title         = b.article_title
    WHEN NOT MATCHED THEN
    INSERT (apex_session_id, author_id, category_id, article_title, article_text)
    VALUES (b.article_id, b.author_id, b.category_id, b.article_title, b.article_text)
    ;
  END save_article_preview;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE create_new_category(
    p_category_name IN VARCHAR2
  )
  AS
    l_category_id NUMBER;
  BEGIN
    INSERT INTO blog_category (category_name, category_seq)
    VALUES(p_category_name, blog_admin_app.get_next_category_seq)
    RETURNING category_id INTO l_category_id;
    sys.htp.prn(l_category_id);
  EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
    sys.htp.prn(apex_lang.message('MSG_CATEGORY_EXISTS'));
  END create_new_category;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE cleanup_category_sequence
  AS
  BEGIN
    MERGE INTO blog_category a
    USING (
      SELECT c.category_id,
        ROW_NUMBER() OVER(ORDER BY c.category_seq) * 10 AS new_seq
      FROM blog_category c
    ) b
    ON (a.category_id = b.category_id)
    WHEN MATCHED THEN UPDATE 
    SET a.category_seq = b.new_seq
    ;
  END cleanup_category_sequence;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE cleanup_faq_sequence
  AS
  BEGIN
    MERGE INTO blog_faq a
    USING (
      SELECT c.faq_id,
        ROW_NUMBER() OVER(ORDER BY c.faq_seq) * 10 AS new_seq
      FROM blog_faq c
    ) b
    ON (a.faq_id = b.faq_id)
    WHEN MATCHED THEN UPDATE 
    SET a.faq_seq = b.new_seq
    ;
  END cleanup_faq_sequence;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE cleanup_author_sequence
  AS
  BEGIN
    MERGE INTO blog_author a
    USING (
      SELECT c.author_id,
        ROW_NUMBER() OVER(ORDER BY c.author_seq) * 10 AS new_seq
      FROM blog_author c
    ) b
    ON (a.author_id = b.author_id)
    WHEN MATCHED THEN UPDATE 
    SET a.author_seq = b.new_seq
    ;
  END cleanup_author_sequence;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE cleanup_resource_sequence
  AS
  BEGIN
    MERGE INTO blog_resource a
    USING (
      SELECT c.link_id,
        ROW_NUMBER() OVER(PARTITION BY c.link_type ORDER BY c.link_seq) * 10 AS new_seq
      FROM blog_resource c
    ) b
    ON (a.link_id = b.link_id)
    WHEN MATCHED THEN UPDATE 
    SET a.link_seq = b.new_seq
    ;
  END cleanup_resource_sequence;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_next_category_seq RETURN NUMBER
  AS
    l_max  NUMBER;
  BEGIN
    SELECT CEIL(COALESCE(MAX(category_seq) + 1, 1) / 10) * 10
    INTO l_max
    FROM blog_category
    ;
    RETURN l_max;
  END get_next_category_seq;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_next_author_seq RETURN NUMBER
  AS
    l_max  NUMBER;
  BEGIN
    SELECT CEIL(COALESCE(MAX(author_seq) + 1, 1) / 10) * 10
    INTO l_max
    FROM blog_author
    ;
    RETURN l_max;
  END get_next_author_seq;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_next_faq_seq RETURN NUMBER
  AS
    l_max  NUMBER;
  BEGIN
    SELECT CEIL(COALESCE(MAX(faq_seq) + 1, 1) / 10) * 10
    INTO l_max
    FROM blog_faq
    ;
    RETURN l_max;
  END get_next_faq_seq;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_next_resource_seq (
    p_link_type IN VARCHAR2
  ) RETURN NUMBER
  AS
    l_max  NUMBER;
  BEGIN
    SELECT CEIL(COALESCE(MAX(link_seq) + 1, 1) / 10) * 10
    INTO l_max
    FROM blog_resource
    WHERE link_type = p_link_type
    ;
    RETURN l_max;
  END get_next_resource_seq;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION set_param_value_item (
    p_param_id          IN VARCHAR2,
    p_yesno             IN VARCHAR2,
    p_text_null         IN VARCHAR2,
    p_number_null       IN VARCHAR2,
    p_number_not_null   IN VARCHAR2,
    p_text_not_null     IN VARCHAR2,
    p_textarea_null     IN VARCHAR2,
    p_textarea_not_null IN VARCHAR2
  ) RETURN VARCHAR2
  AS
    l_value VARCHAR2(32700);
  BEGIN
    SELECT CASE
      WHEN param_type = 'YESNO' THEN
        p_yesno
      WHEN param_type = 'TEXT' AND param_nullable = 'Y' THEN
        p_text_null
      WHEN param_type = 'TEXT' AND param_nullable = 'N' THEN
        p_text_not_null
      WHEN param_type = 'NUMBER' AND param_nullable = 'Y' THEN
        p_number_null
      WHEN param_type = 'NUMBER' AND param_nullable = 'N' THEN
        p_number_not_null
      WHEN param_type = 'TEXTAREA' AND param_nullable = 'Y' THEN
        p_textarea_null
      WHEN param_type = 'TEXTAREA' AND param_nullable = 'N' THEN
        p_textarea_not_null
    END AS param_value
    INTO l_value
    FROM blog_param
    WHERE param_id = p_param_id
    ;
    RETURN l_value;
  END set_param_value_item;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION login(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN
  AS
    AUTH_SUCCESS            CONSTANT INTEGER      := 0;
    AUTH_UNKNOWN_USER       CONSTANT INTEGER      := 1;
    AUTH_ACCOUNT_LOCKED     CONSTANT INTEGER      := 2;
    AUTH_ACCOUNT_EXPIRED    CONSTANT INTEGER      := 3;
    AUTH_PASSWORD_INCORRECT CONSTANT INTEGER      := 4;
    AUTH_PASSWORD_FIRST_USE CONSTANT INTEGER      := 5;
    AUTH_ATTEMPTS_EXCEEDED  CONSTANT INTEGER      := 6;
    AUTH_INTERNAL_ERROR     CONSTANT INTEGER      := 7;
    l_password              VARCHAR2(4000);
    l_stored_password       VARCHAR2(4000);
  BEGIN
    -- First, check to see if the user is in the user table and have password
    BEGIN
      SELECT passwd
      INTO l_stored_password
      FROM blog_author
      WHERE user_name = p_username
      AND active = 'Y'
      AND passwd IS NOT NULL
      ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      APEX_UTIL.SET_AUTHENTICATION_RESULT(AUTH_UNKNOWN_USER);
      RETURN FALSE;
    END;
    -- Apply the custom hash function to the password
    l_password := blog_pw_hash(p_username, p_password);
    -- Compare them to see if they are the same and return either TRUE or FALSE
    IF l_password = l_stored_password THEN
      APEX_UTIL.SET_AUTHENTICATION_RESULT(AUTH_SUCCESS);
      RETURN TRUE;
    END IF;
    APEX_UTIL.SET_AUTHENTICATION_RESULT(AUTH_PASSWORD_INCORRECT);
    RETURN FALSE;
  END login;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION check_password (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN
  AS
    l_password              VARCHAR2(4000);
    l_stored_password       VARCHAR2(4000);
  BEGIN
    -- First, check to see if the user is in the user table and have password
    BEGIN
      SELECT passwd
      INTO l_stored_password
      FROM blog_author
      WHERE user_name = p_username
      AND active = 'Y'
      AND passwd IS NOT NULL
      ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
    END;
    -- Apply the custom hash function to the password
    l_password := blog_pw_hash(p_username, p_password);
    -- Compare them to see if they are the same and return either TRUE or FALSE
    IF l_password = l_stored_password THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END check_password;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE post_login
  AS
    l_app_user  VARCHAR2(255);
    l_author_id NUMBER;
    l_app_id    NUMBER;
    l_reader_id NUMBER;
  BEGIN
    l_app_user  := v('APP_USER');
    l_app_id    := nv('APP_ID');
    SELECT author_id
      INTO l_author_id
      FROM blog_author
     WHERE user_name = l_app_user
      AND active = 'Y'
      AND passwd IS NOT NULL
    ;
    blog_util.set_items_from_param(l_app_id);
    apex_util.set_session_state('G_AUTHOR_ID', l_author_id);
    apex_util.set_session_state('G_DATE_TIME_FORMAT', COALESCE(apex_util.get_preference('DATE_TIME_FORMAT', l_app_user), 'DD Mon YYYY HH24:MI:SS'));
    IF apex_util.get_preference('SHOW_HELP', l_app_user) IS NULL THEN
      apex_util.set_preference(
        p_preference => 'SHOW_HELP',
        p_value => 'Y',
        p_user => l_app_user
      );
    END IF;
    l_reader_id := nv('G_BLOG_READER_APP_ID');
    FOR c1 IN (
      SELECT alias
      FROM apex_applications
      WHERE application_id = l_reader_id
    ) LOOP
      apex_util.set_session_state('G_BLOG_READER_APP_ALIAS', c1.alias);
    END LOOP;
  END post_login;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION is_developer RETURN PLS_INTEGER
  AS
  BEGIN
    RETURN CASE WHEN apex_authorization.is_authorized('IS_DEVELOPER') THEN 1 ELSE 0 END;
  END ;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE get_apex_lang_message (
    p_application_id        IN NUMBER,
    p_translation_entry_id  IN NUMBER,
    p_translatable_message  OUT NOCOPY VARCHAR2,
    p_language_code         OUT NOCOPY VARCHAR2,
    p_message_text          OUT NOCOPY VARCHAR2,
    p_md5                   OUT NOCOPY VARCHAR2
   )
   AS
   BEGIN
    FOR c1 IN (
      SELECT translation_entry_id
        ,translatable_message
        ,language_code
        ,message_text
      FROM apex_application_translations
      WHERE application_id = p_application_id
        AND translation_entry_id = p_translation_entry_id
    ) LOOP
      p_translatable_message := c1.translatable_message;
      p_language_code := c1.language_code;
      p_message_text := c1.message_text;
      p_md5 := build_apex_lang_message_md5 (
          c1.translation_entry_id,
          c1.translatable_message,
          c1.language_code,
          c1.message_text 
      );
    END LOOP;
  END get_apex_lang_message;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE upd_apex_lang_message (
    p_application_id        IN NUMBER,
    p_translation_entry_id  IN NUMBER,
    p_translatable_message  IN VARCHAR2,
    p_language_code         IN VARCHAR2,
    p_message_text          IN VARCHAR2,
    p_md5                   IN VARCHAR2,
    p_success_message       OUT NOCOPY VARCHAR2
  )
  AS
    l_input_md5 varchar2(32676);
    l_table_md5 varchar2(32676);
  BEGIN
    l_input_md5 := build_apex_lang_message_md5 (
        p_translation_entry_id,
        p_translatable_message,
        p_language_code,
        p_message_text 
     );
    IF p_md5 IS NOT NULL THEN
      FOR c1 IN (
        SELECT translation_entry_id
          ,translatable_message
          ,language_code
          ,message_text
        FROM apex_application_translations
        WHERE application_id = p_application_id
        AND translation_entry_id = p_translation_entry_id
      ) LOOP
          l_table_md5 := build_apex_lang_message_md5 (
              c1.translation_entry_id,
              c1.translatable_message,
              c1.language_code,
              c1.message_text 
           );
      END LOOP;
    END IF;
    IF l_table_md5 != p_md5 THEN
      raise_application_error (-20001, apex_lang.message('MSG_LOST_UPDATE', l_table_md5, p_md5));
    ELSIF p_md5       IS NOT NULL
    AND   l_table_md5 IS NOT NULL
    AND   l_table_md5 = p_md5
    AND   l_input_md5 != p_md5
    THEN
      apex_lang.update_message(
        p_id => p_translation_entry_id,
        p_message_text => p_message_text
      );
      p_success_message := apex_lang.message('MSG_ACTION_PROCESSED');
    END IF;
  END upd_apex_lang_message;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_ADMIN_APP";
/