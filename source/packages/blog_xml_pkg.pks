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
END "BLOG_XML";
/
