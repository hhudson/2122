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
  PROCEDURE notify_readers (
    p_comment_id      IN NUMBER,
    p_user_id         IN NUMBER,
    p_page_id      IN NUMBER,
    p_page_title   IN VARCHAR2,
    p_app_alias       IN VARCHAR2,
    p_base_url        IN VARCHAR2,
    p_blog_name       IN VARCHAR2
  );
--------------------------------------------------------------------------------
  PROCEDURE unsubscribe (
    p_value           IN OUT NOCOPY VARCHAR2,
    p_user_id         OUT NOCOPY NUMBER,
    p_page_id      OUT NOCOPY NUMBER
  );
--------------------------------------------------------------------------------
  PROCEDURE download_file (
    p_file_name       IN VARCHAR2,
    p_session_id      IN NUMBER,
    p_user_id         IN VARCHAR2
  );
--------------------------------------------------------------------------------
  FUNCTION validate_email (
    p_email           IN VARCHAR2
  ) RETURN BOOLEAN;
--------------------------------------------------------------------------------
  /*PROCEDURE get_page_page_items (
    p_page_id      IN VARCHAR2,
    p_page_title      OUT NOCOPY VARCHAR2,
    p_region_title    OUT NOCOPY VARCHAR2,
    p_keywords        OUT NOCOPY VARCHAR2,
    p_description     OUT NOCOPY VARCHAR2,
    p_author_name     OUT NOCOPY VARCHAR2,
    p_twitter_follow  OUT NOCOPY VARCHAR2,
    p_rate            OUT NOCOPY NUMBER
  );*/
--------------------------------------------------------------------------------
  PROCEDURE get_category_page_items (
    p_category_id     IN VARCHAR2,
    p_page_title      OUT NOCOPY VARCHAR2,
    p_region_title    OUT NOCOPY VARCHAR2,
    p_category_name   OUT NOCOPY VARCHAR2
  );
--------------------------------------------------------------------------------
END "BLOG_UTIL";
/