create or replace PACKAGE  "BLOG_JOB" 
AUTHID DEFINER
AS
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE rotate_log;
--------------------------------------------------------------------------------
  PROCEDURE update_country;
--------------------------------------------------------------------------------
  PROCEDURE update_activity_logs;
--------------------------------------------------------------------------------
  PROCEDURE purge_preview;
--------------------------------------------------------------------------------
  PROCEDURE rotate_log_job (
    p_drop_job IN BOOLEAN DEFAULT FALSE,
    p_interval IN PLS_INTEGER DEFAULT NULL
  );
--------------------------------------------------------------------------------
  PROCEDURE update_country_job (
    p_drop_job IN BOOLEAN DEFAULT FALSE
  );
--------------------------------------------------------------------------------
  PROCEDURE update_activity_logs_job (
    p_drop_job IN BOOLEAN DEFAULT FALSE
  );
--------------------------------------------------------------------------------
  PROCEDURE purge_preview_job (
    p_drop_job IN BOOLEAN DEFAULT FALSE
  );
--------------------------------------------------------------------------------
END "BLOG_JOB";
/