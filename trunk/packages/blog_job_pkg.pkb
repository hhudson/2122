create or replace PACKAGE BODY  "BLOG_JOB" 
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
  PROCEDURE get_host_ip_info (
    p_ip            IN VARCHAR2,
    p_city          OUT NOCOPY VARCHAR2,
    p_country_code  OUT NOCOPY VARCHAR2
  )
  AS
    l_clob  CLOB;
    l_url   CONSTANT VARCHAR2(32000) := 'http://api.hostip.info/';
  BEGIN
    l_clob := apex_web_service.make_rest_request(
                p_url         => l_url,
                p_http_method => 'GET',
                p_parm_name   => apex_util.string_to_table('ip'),
                p_parm_value  => apex_util.string_to_table(p_ip)
              );
    BEGIN
      SELECT EXTRACTVALUE(VALUE(t), '//gml:name', 'xmlns:gml="http://www.opengis.net/gml"')  AS city,
        EXTRACTVALUE(VALUE(t), '//countryAbbrev', 'xmlns:gml="http://www.opengis.net/gml"')  AS countryAbbrev
      INTO p_city, p_country_code
      FROM TABLE(
        XMLSEQUENCE(
          XMLTYPE.CREATEXML(l_clob).EXTRACT(
            'HostipLookupResultSet/gml:featureMember/Hostip',
            'xmlns:gml="http://www.opengis.net/gml"'
          )
        )
      ) t;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      p_city          := NULL;
      p_country_code  := NULL;
    END;
 
  END get_host_ip_info;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Global functions and procedures
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE rotate_log
  AS
    l_new_tbl VARCHAR2(4000);
    l_log_tbl CHAR(1);
  BEGIN
  
    SELECT SUBSTR(table_name, -1) AS log_tbl
    INTO l_log_tbl
    FROM user_synonyms
    WHERE synonym_name = 'BLOG_ACTIVITY_LOG'
    ;
    
    IF l_log_tbl = '1' THEN
      l_new_tbl := '2';
    ELSIF l_log_tbl = '2' THEN
      l_new_tbl := '1';
    ELSE
      raise_application_error(-20001, 'Invalid log table.');
    END IF;
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE BLOG_ACTIVITY_LOG' || l_new_tbl;
    
    EXECUTE IMMEDIATE 'CREATE OR REPLACE SYNONYM BLOG_ACTIVITY_LOG FOR BLOG_ACTIVITY_LOG' || l_new_tbl;
  
  END rotate_log;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE update_country
  AS
    l_city    VARCHAR2(2000);
    l_code    VARCHAR2(2000);
    l_count   NUMBER;
  BEGIN
  
    /* Get distinct ip addreses where is no country information. */
    FOR c1 IN(
      SELECT DISTINCT ip_address
      FROM blog_activity_log
      WHERE activity_type = 'NEW_SESSION'
      AND country_code IS NULL
    ) LOOP
    
      l_count := 0;
      l_city  := NULL;
      l_code  := NULL;
      
      /* Check from logs if ip address already have country information from previous visit */
      BEGIN
        WITH qry AS (
          SELECT
            ROW_NUMBER() OVER(ORDER BY activity_date DESC) AS rn,
            country_city,
            country_code
          FROM blog_v$activity_log
          WHERE activity_type = 'NEW_SESSION'
          AND ip_address = c1.ip_address
          AND country_code IS NOT NULL
        )
        SELECT
          country_city,
          country_code
        INTO l_city, l_code
        FROM qry
        WHERE rn = 1
        ;
      /* If no previous visit get country info from hostip.info */
      EXCEPTION WHEN NO_DATA_FOUND THEN    
        get_host_ip_info(
          p_ip            => c1.ip_address,
          p_city          => l_city,
          p_country_code  => l_code
        );
      END;
      
      l_city  := COALESCE(l_city, '(unknown city)');
      l_code  := COALESCE(l_code, 'XX');
      
      /* Update activity log if country code exists in BLOG_COUNTRY table */
      UPDATE blog_activity_log
      SET country_city  = l_city,
        country_code    = l_code
      WHERE activity_type = 'NEW_SESSION'
        AND ip_address  = c1.ip_address
        AND country_code IS NULL
        AND EXISTS (
          SELECT 1
          FROM blog_country c
          WHERE c.country_code = l_code
        )
      ;
      l_count := SQL%ROWCOUNT;
      
      /* If no rows updated, country code is unknown */
      IF l_count = 0 THEN
        l_code := 'XX';    
        UPDATE blog_activity_log
        SET country_city  = l_city,
          country_code    = l_code
        WHERE activity_type = 'NEW_SESSION'
          AND ip_address  = c1.ip_address
          AND country_code IS NULL
          ;
        l_count := SQL%ROWCOUNT;
      END IF;
      
      /* Update total visitors from country */
      UPDATE blog_country
      SET visit_count = visit_count + l_count
      WHERE country_code = l_code
      ;
      
    END LOOP;
    
  END update_country;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE update_activity_logs
  AS
  BEGIN
    dbms_mview.refresh('BLOG_ARTICLE_HIT20,BLOG_ARTICLE_TOP20');
  END update_activity_logs;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE purge_preview
  AS
  BEGIN
    /* Delete from blog_article_preview rows where session is expired */
    DELETE FROM blog_article_preview p
    WHERE NOT EXISTS (
      SELECT 1 FROM apex_workspace_sessions s
      WHERE s.apex_session_id = p.apex_session_id
    );
  END purge_preview;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE rotate_log_job(
    p_drop_job IN BOOLEAN DEFAULT FALSE,
    p_interval IN PLS_INTEGER DEFAULT NULL
  )
  AS
    l_interval        SIMPLE_INTEGER := 0;
    c_job             CONSTANT VARCHAR2(30) := 'BLOG_ROTATE_LOG';
    job_not_exists    EXCEPTION;
    PRAGMA            EXCEPTION_INIT(job_not_exists, -27475);
  BEGIN
    BEGIN
      sys.dbms_scheduler.drop_job(c_job);
    EXCEPTION WHEN job_not_exists THEN
      NULL;
    END;
    
    IF p_interval IS NULL OR p_interval < 1 THEN
      l_interval := blog_util.get_param_value('LOG_ROTATE_DAY');
    ELSE
      l_interval := p_interval;
    END IF;
    IF NOT p_drop_job THEN
      sys.dbms_scheduler.create_job(
        job_name        => c_job,
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'blog_job.rotate_log',
        start_date      => TRUNC(SYSTIMESTAMP),
        enabled         => TRUE,
        repeat_interval => 'FREQ=DAILY;INTERVAL=' || l_interval || ';BYMINUTE=5',
        comments        => 'Rotate blog activity logs'
      );
    END IF;
  END rotate_log_job;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE update_country_job (
    p_drop_job BOOLEAN DEFAULT FALSE
  )
  AS
    c_job                 CONSTANT VARCHAR2(30) := 'BLOG_UPDATE_COUNTRY';
    job_not_exists        EXCEPTION;
    PRAGMA                EXCEPTION_INIT(job_not_exists, -27475);
  BEGIN
    BEGIN
      sys.dbms_scheduler.drop_job(c_job);
    EXCEPTION WHEN job_not_exists THEN
      NULL;
    END;
    
    IF NOT p_drop_job THEN
      sys.dbms_scheduler.create_job(
        job_name        => c_job,
        job_type        =>'STORED_PROCEDURE',
        job_action      => 'blog_job.update_country',
        start_date      => TRUNC(SYSTIMESTAMP, 'HH'),
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=10',
        enabled         => TRUE,
        comments        => 'Update blog visitors country'
      );
    END IF;
  END update_country_job;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE update_activity_logs_job (
    p_drop_job BOOLEAN DEFAULT FALSE
  )
  AS
    c_job          CONSTANT VARCHAR2(30) := 'BLOG_UPDATE_ACTIVITY_LOGS';
    job_not_exists EXCEPTION;
    PRAGMA         EXCEPTION_INIT(job_not_exists, -27475);
  BEGIN
    BEGIN
      sys.dbms_scheduler.drop_job(c_job);
    EXCEPTION WHEN job_not_exists THEN
      NULL;
    END;
    
    IF NOT p_drop_job THEN
      sys.dbms_scheduler.create_job(
        job_name        => c_job,
        job_type        =>'STORED_PROCEDURE',
        job_action      => 'blog_job.update_activity_logs',
        start_date      => TRUNC(SYSTIMESTAMP, 'HH'),
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=15',
        enabled         => TRUE,
        comments        => 'Update blog statistic log mviews'
      );
    END IF;
  END update_activity_logs_job;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE purge_preview_job(
    p_drop_job BOOLEAN DEFAULT FALSE
  )
  AS
    c_job           CONSTANT VARCHAR2(30) := 'BLOG_PURGE_PREVIEW';
    job_not_exists  EXCEPTION;
    PRAGMA          EXCEPTION_INIT(job_not_exists, -27475);
  BEGIN
    BEGIN
      sys.dbms_scheduler.drop_job(c_job);
    EXCEPTION WHEN job_not_exists THEN
      NULL;
    END;
    IF NOT p_drop_job THEN
      sys.dbms_scheduler.create_job(
        job_name        => c_job,
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'blog_job.purge_preview',
        start_date      => TRUNC(SYSTIMESTAMP),
        repeat_interval => 'FREQ=DAILY',
        enabled         => TRUE,
        comments        => 'Purge blog article preview table'
      );
    END IF;
  END purge_preview_job;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_JOB";
/