create or replace PACKAGE  "BLOG_UTIL" 
AUTHID DEFINER
AS
--------------------------------------------------------------------------------
  FUNCTION init_session (
    p_app_id          IN NUMBER,
    p_session_id      IN NUMBER
  ) RETURN NUMBER;
--------------------------------------------------------------------------------
  FUNCTION get_param_value (
    p_param_id        IN VARCHAR2
  ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
  PROCEDURE set_items_from_param (
    p_app_id          IN NUMBER
  );
--------------------------------------------------------------------------------
  PROCEDURE save_comment(
    p_user_id         IN OUT NOCOPY NUMBER,
    p_apex_session_id IN NUMBER,
    p_app_alias       IN VARCHAR2,
    p_base_url        IN VARCHAR2,
    p_blog_name       IN VARCHAR2,
    p_page_id      IN NUMBER,
    p_page_title   IN VARCHAR2,
    p_email           IN VARCHAR2,
    p_nick_name       IN VARCHAR2,
    p_website         IN VARCHAR2,
    p_followup        IN VARCHAR2,
    p_comment         IN VARCHAR2
  );
--------------------------------------------------------------------------------
  PROCEDURE save_contact (
    p_user_id         IN OUT NOCOPY NUMBER,
    p_apex_session_id IN NUMBER,
    p_email           IN VARCHAR2,
    p_nick_name       IN VARCHAR2,
    p_website         IN VARCHAR2,
    p_comment         IN VARCHAR2
  );
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
PROCEDURE notify_blog_commenters (
    p_comment_id    IN NUMBER,
    p_page_id       IN NUMBER
  );
--------------------------------------------------------------------------------
  PROCEDURE unsubscribe (
    p_value           IN OUT NOCOPY VARCHAR2,
    p_user_id         OUT NOCOPY NUMBER,
    p_page_id      OUT NOCOPY NUMBER
  );
--------------------------------------------------------------------------------
  
  FUNCTION validate_email (
    p_email           IN VARCHAR2
  ) RETURN BOOLEAN;
--------------------------------------------------------------------------------
  
END "BLOG_UTIL";
/