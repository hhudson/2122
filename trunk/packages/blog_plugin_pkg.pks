create or replace PACKAGE  "BLOG_PLUGIN" 
AUTHID DEFINER
AS
-------------------------------------------------------------------------------
  g_formatted_comment VARCHAR2(32700);
  g_question_answer   PLS_INTEGER;
-------------------------------------------------------------------------------
  FUNCTION render_comment_textarea(
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
-------------------------------------------------------------------------------
  FUNCTION validate_comment_textarea(
    p_item   IN apex_plugin.t_page_item,
    p_plugin IN apex_plugin.t_plugin,
    p_value  IN VARCHAR2
  ) RETURN apex_plugin.t_page_item_validation_result;
--------------------------------------------------------------------------------
  FUNCTION feature_authorization (
    p_authorization in apex_plugin.t_authorization,
    p_plugin        in apex_plugin.t_plugin
  ) RETURN apex_plugin.t_authorization_exec_result;
--------------------------------------------------------------------------------
  FUNCTION render_math_question_field(
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
--------------------------------------------------------------------------------
  FUNCTION ajax_math_question_field(
    p_item   in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin
  ) RETURN apex_plugin.t_page_item_ajax_result;
--------------------------------------------------------------------------------
  FUNCTION validate_math_question_field(
    p_item   IN apex_plugin.t_page_item,
    p_plugin IN apex_plugin.t_plugin,
    p_value  IN VARCHAR2
  ) RETURN apex_plugin.t_page_item_validation_result;
--------------------------------------------------------------------------------
  FUNCTION render_simple_star_rating (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
--------------------------------------------------------------------------------
  FUNCTION render_modal_confirm(
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin
  ) RETURN apex_plugin.t_dynamic_action_render_result;
--------------------------------------------------------------------------------
  FUNCTION render_google_plus_one_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
--------------------------------------------------------------------------------
  FUNCTION render_google_share_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
-------------------------------------------------------------------------------
  FUNCTION render_facebook_like_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
-------------------------------------------------------------------------------
  FUNCTION render_twitter_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result;
-------------------------------------------------------------------------------
END "BLOG_PLUGIN";
