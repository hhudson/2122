create or replace PACKAGE  "BLOG_INSTALL" 
AUTHID DEFINER
AS
--------------------------------------------------------------------------------
  i sys.dbms_sql.varchar2_table;
  e sys.dbms_sql.varchar2_table;
  b BLOB;
--------------------------------------------------------------------------------
  PROCEDURE update_param_data(
    p_theme_path    IN VARCHAR2 DEFAULT NULL,
    p_upgrade       IN BOOLEAN DEFAULT FALSE
  );
--------------------------------------------------------------------------------
  FUNCTION varchar2_to_blob(
    p_varchar2_tab IN sys.dbms_sql.varchar2_table
  ) RETURN BLOB;
--------------------------------------------------------------------------------
  PROCEDURE set_jobs (
    p_drop_job IN BOOLEAN DEFAULT FALSE
  );
--------------------------------------------------------------------------------
  FUNCTION get_version (
    p_option  IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
END "BLOG_INSTALL";