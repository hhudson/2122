create or replace PACKAGE BODY  "BLOG_INSTALL" 
AS
--------------------------------------------------------------------------------
--the below is part of logger best practices
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE update_param_data(
    p_theme_path    IN VARCHAR2 DEFAULT NULL,
    p_upgrade       IN BOOLEAN DEFAULT FALSE
  )
  AS
    l_reader_id NUMBER;
    l_admin_id  NUMBER;
    l_app_alias VARCHAR2(2000);
    l_base_url  VARCHAR2(2000);
  BEGIN
    l_base_url := apex_util.host_url('SCRIPT');
    BEGIN
      SELECT application_id
      INTO l_reader_id
      FROM apex_applications
      WHERE version = (select blog_util.get_param_value('READER_VERSION') from dual)
        AND application_group = 'Blog'
        AND application_name = 'Blog Reader'
      ;
    EXCEPTION WHEN 
      NO_DATA_FOUND 
    THEN
      raise_application_error(-20001, 'Blog reader application not exists.');
    END;
    BEGIN
      SELECT application_id
      INTO l_admin_id
      FROM apex_applications
      WHERE version = (select blog_util.get_param_value('ADMIN_VERSION') from dual)
        AND application_group = 'Blog'
        AND application_name = 'Blog Administration'
      ;
    EXCEPTION WHEN 
      NO_DATA_FOUND
    THEN
      raise_application_error(-20002, 'Blog admin application not exists.');
    END;
    
    SELECT alias
    INTO l_app_alias
    FROM apex_applications
    WHERE application_id = l_reader_id
    ;
    UPDATE blog_param
    SET param_value = TO_CHAR(l_reader_id)
    WHERE param_id  = 'G_BLOG_READER_APP_ID'
    ;
    UPDATE blog_param
    SET param_value = TO_CHAR(l_admin_id)
    WHERE param_id  = 'G_BLOG_ADMIN_APP_ID'
    ;
    IF NOT p_upgrade THEN
      UPDATE blog_param
      SET param_value = coalesce(p_theme_path,'f?p=' || TO_CHAR(l_reader_id) || ':DOWNLOAD:0:')
      WHERE param_id  = 'G_THEME_PATH'
      ;
      UPDATE blog_param
      SET param_value = l_base_url || 'f?p=' || l_app_alias || ':RSS'
      WHERE param_id  = 'G_RSS_FEED_URL'
      ;
      UPDATE blog_param
      SET param_value = l_base_url
      WHERE param_id  = 'G_BASE_URL'
      ;
      dbms_mview.refresh('BLOG_PARAM_APP','C');
    END IF;
  END update_param_data;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION varchar2_to_blob(
    p_varchar2_tab IN sys.dbms_sql.varchar2_table
  ) RETURN BLOB
  AS
    l_blob BLOB;
    l_size NUMBER;
  BEGIN
    dbms_lob.createtemporary(l_blob, true, dbms_lob.session);
    FOR i IN 1 .. p_varchar2_tab.count
    LOOP
      l_size := length(p_varchar2_tab(i)) / 2;
      dbms_lob.writeappend(l_blob, l_size, hextoraw(p_varchar2_tab(i)));
    END LOOP;
    RETURN l_blob;
  EXCEPTION WHEN OTHERS THEN
    dbms_lob.close(l_blob);
    RETURN NULL;
  END varchar2_to_blob;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE set_jobs (
    p_drop_job IN BOOLEAN DEFAULT FALSE
  )
  AS
  BEGIN
    blog_job.rotate_log_job(p_drop_job);
    blog_job.purge_preview_job(p_drop_job);
    blog_job.update_country_job(p_drop_job);
    blog_job.update_activity_logs_job(p_drop_job);
  END set_jobs;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION get_version (
    p_option  IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2
  AS
    l_version VARCHAR2(256);
  BEGIN
    IF p_option = 'READER' THEN
      BEGIN
        SELECT s.version
         INTO l_version
         FROM apex_applications s
        WHERE s.application_id = (select blog_util.get_param_value('G_BLOG_READER_APP_ID') from dual)
          AND s.version = (select blog_util.get_param_value('READER_VERSION') from dual)
        ;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001, 'Blog reader application not exists.');
      END;
    ELSIF p_option = 'ADMIN' THEN
      BEGIN
        SELECT s.version
         INTO l_version
         FROM apex_applications s
        WHERE s.application_id = (select blog_util.get_param_value('G_BLOG_ADMIN_APP_ID') from dual)
          AND s.version = (select blog_util.get_param_value('ADMIN_VERSION') from dual)
        ;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001, 'Blog admin application not exists.');
      END;
    ELSE
      l_version :=  blog_util.get_param_value('SCHEMA_VERSION');
    END IF;
    RETURN l_version;    
  END get_version;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_INSTALL";
/