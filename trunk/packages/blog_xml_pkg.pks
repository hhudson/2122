create or replace PACKAGE  "BLOG_XML" 
AUTHID DEFINER
AS
--------------------------------------------------------------------------------
  FUNCTION show_entry(
    p_build_option_id         IN VARCHAR2,
    p_authorization_scheme_id IN VARCHAR2,
    p_condition_type_code     IN VARCHAR2,
    p_condition_expression1   IN VARCHAR2,
    p_condition_expression2   IN VARCHAR2
  ) RETURN VARCHAR2;
--------------------------------------------------------------------------------
  PROCEDURE rss(
    p_app_alias IN VARCHAR2,
    p_blog_name IN VARCHAR2,
    p_base_url  IN VARCHAR2
  );
--------------------------------------------------------------------------------
  PROCEDURE sitemap(
    p_app_id    IN NUMBER,
    p_app_alias IN VARCHAR2,
    p_base_url  IN VARCHAR2,
    p_tab_list  IN VARCHAR2
  );
--------------------------------------------------------------------------------
END "BLOG_XML";
