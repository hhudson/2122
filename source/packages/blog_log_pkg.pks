create or replace PACKAGE  "BLOG_LOG" 
AUTHID DEFINER
AS
-------------------------------------------------------------------------------
  FUNCTION apex_error_handler(
    p_error IN apex_error.t_error
  ) RETURN apex_error.t_error_result;
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
  );
--------------------------------------------------------------------------------
  /*PROCEDURE write_article_log(
    p_article_id      IN NUMBER
  );*/
--------------------------------------------------------------------------------
  /*PROCEDURE rate_article(
    p_article_id      IN NUMBER,
    p_article_rate    IN OUT NOCOPY NUMBER
  );*/
--------------------------------------------------------------------------------
  PROCEDURE write_category_log(
    p_category_id     IN NUMBER
  );
--------------------------------------------------------------------------------
  PROCEDURE write_file_log(
    p_file_id         IN NUMBER
  );
--------------------------------------------------------------------------------
END "BLOG_LOG";
/
