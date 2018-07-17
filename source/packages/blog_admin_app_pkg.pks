create or replace PACKAGE  "BLOG_ADMIN_APP" 
AUTHID DEFINER
AS
--------------------------------------------------------------------------------
  PROCEDURE refresh_article_mview;
--------------------------------------------------------------------------------
  FUNCTION get_collection_name RETURN VARCHAR2;
--------------------------------------------------------------------------------
  PROCEDURE print_article_from_collection;
--------------------------------------------------------------------------------
  PROCEDURE table_to_collection (
    p_table       IN APEX_APPLICATION_GLOBAL.VC_ARR2
  );
--------------------------------------------------------------------------------  
  PROCEDURE create_new_category(
    p_category_name IN VARCHAR2
  );
--------------------------------------------------------------------------------
  PROCEDURE cleanup_category_sequence;
--------------------------------------------------------------------------------
  PROCEDURE cleanup_faq_sequence;
--------------------------------------------------------------------------------
  PROCEDURE cleanup_author_sequence;
--------------------------------------------------------------------------------
  --PROCEDURE cleanup_resource_sequence;
--------------------------------------------------------------------------------
  FUNCTION get_next_category_seq RETURN NUMBER;
--------------------------------------------------------------------------------
  FUNCTION get_next_author_seq RETURN NUMBER;
--------------------------------------------------------------------------------
  FUNCTION get_next_faq_seq RETURN NUMBER;
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
  ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
  FUNCTION login(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN;
--------------------------------------------------------------------------------
  FUNCTION check_password(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
  ) RETURN BOOLEAN;
--------------------------------------------------------------------------------
  PROCEDURE post_login;
--------------------------------------------------------------------------------
  FUNCTION is_developer RETURN PLS_INTEGER;
--------------------------------------------------------------------------------
  PROCEDURE get_apex_lang_message (
    p_application_id        IN NUMBER,
    p_translation_entry_id  IN NUMBER,
    p_translatable_message  OUT NOCOPY VARCHAR2,
    p_language_code         OUT NOCOPY VARCHAR2,
    p_message_text          OUT NOCOPY VARCHAR2,
    p_md5                   OUT NOCOPY VARCHAR2
   );
--------------------------------------------------------------------------------
  PROCEDURE upd_apex_lang_message (
    p_application_id        IN NUMBER,
    p_translation_entry_id  IN NUMBER,
    p_translatable_message  IN VARCHAR2,
    p_language_code         IN VARCHAR2,
    p_message_text          IN VARCHAR2,
    p_md5                   IN VARCHAR2,
    p_success_message       OUT NOCOPY VARCHAR2
   );
--------------------------------------------------------------------------------  
END "BLOG_ADMIN_APP";
/