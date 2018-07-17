create or replace PACKAGE BODY  "BLOG_XML" 
AS
--------------------------------------------------------------------------------
--the below is part of logger best practices
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION show_entry(
    p_build_option_id         IN VARCHAR2,
    p_authorization_scheme_id IN VARCHAR2,
    p_condition_type_code     IN VARCHAR2,
    p_condition_expression1   IN VARCHAR2,
    p_condition_expression2   IN VARCHAR2
  ) RETURN VARCHAR2
  AS
    l_retval  BOOLEAN;
  BEGIN
    l_retval := apex_plugin_util.is_component_used (
      p_build_option_id         => p_build_option_id,
      p_authorization_scheme_id => p_authorization_scheme_id,
      p_condition_type          => p_condition_type_code,
      p_condition_expression1   => p_condition_expression1,
      p_condition_expression2   => p_condition_expression2
    );
    RETURN apex_debug.tochar(l_retval);
  END show_entry;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

END "BLOG_XML";
/
