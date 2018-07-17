set define off;
create or replace PACKAGE BODY  "BLOG_PLUGIN" 
AS
--------------------------------------------------------------------------------
--the below is part of logger best practices
gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- private variables, procedures and functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  g_whitelist_tags        CONSTANT VARCHAR2(200)  := '<b>,</b>,<i>,</i>,<u>,</u>,<code>,</code>';
  g_code_open             CONSTANT VARCHAR2(30)   := '<code>';
  g_code_close            CONSTANT VARCHAR2(30)   := '</code>';
  g_syntaxhighlight_open  CONSTANT VARCHAR2(100)  := '<pre class="brush:plain" style="background-color:#eeeeee;padding:2px;">';
  g_syntaxhighlight_close CONSTANT VARCHAR2(30)   := '</pre>';
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION format_comment(
    p_comment         IN VARCHAR2,
    p_whitelist_tags  IN VARCHAR2
  ) RETURN VARCHAR2
  AS
    l_comment               VARCHAR2(32700);
    l_temp                  VARCHAR2(32700);
    l_len_s                 NUMBER := 0;
    l_len_e                 NUMBER := 0;
    l_count_open            SIMPLE_INTEGER := 0;
    l_count_close           SIMPLE_INTEGER := 0;
    l_start                 SIMPLE_INTEGER := 0;
    l_end                   SIMPLE_INTEGER := 0;
    l_comment_arr           apex_application_global.vc_arr2;
    l_code_arr              apex_application_global.vc_arr2;
  BEGIN
    l_len_s := LENGTH(g_code_open);
    l_len_e := LENGTH(g_code_close);
    /* Change all hash marks so we can escape those later*/
    l_comment := REPLACE(p_comment, '#', '$@#HASH#@$');
    /* escape comment html */
    l_comment := APEX_ESCAPE.HTML_WHITELIST (
      p_html            => l_comment,
      p_whitelist_tags  => p_whitelist_tags
    );
    /* Escape hash to e.g. prevent APEX substitutions */
    l_comment := REPLACE(l_comment, '$@#HASH#@$', '&#x23;');
    /* check code tag count */
    l_count_open  := regexp_count(l_comment, g_code_open);
    l_count_close := regexp_count(l_comment, g_code_close);
    /* Process code tags */
    IF l_count_open = l_count_close THEN
      /* Store text inside code tags to array while format rest of message*/
      FOR i IN 1 .. l_count_open
      LOOP
        l_start       := INSTR(l_comment, g_code_open);
        l_end         := INSTR(l_comment, g_code_close);
        l_code_arr(i) := g_syntaxhighlight_open
                      || SUBSTR(l_comment, l_start  + l_len_s, l_end - l_start - l_len_s)
                      || g_syntaxhighlight_close;
        l_comment     := SUBSTR(l_comment, 1, l_start -1)
                      || chr(10)
                      || '$@#' || i || '#@$'
                      || chr(10)
                      || SUBSTR(l_comment, l_end + l_len_e);
      END LOOP;
      /* Format message */
      l_comment_arr := APEX_UTIL.STRING_TO_TABLE(l_comment, chr(10));
      l_comment := NULL;
      FOR i IN 1 .. l_comment_arr.COUNT
      LOOP
        /* Remove empty lines and do not add extra tags for code */
        l_temp := TRIM(l_comment_arr(i));
        IF REGEXP_LIKE(l_temp, '^\$\@\#[0-9]+\#\@\$$') THEN
          l_comment := l_comment || l_temp;
        ELSIF l_temp IS NOT NULL THEN
          l_comment := l_comment || '<p>' || l_temp || '</p>';
        END IF;
      END LOOP;
      /* insert code tags back to comment */
      FOR i IN 1 .. l_code_arr.COUNT
      LOOP
        l_comment := REPLACE(l_comment, '$@#' || i || '#@$', l_code_arr(i));
      END LOOP;
    END IF;
    RETURN l_comment;
  END format_comment;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Global procedures and functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_comment_textarea(
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    l_name        VARCHAR2(30);
    l_code        VARCHAR2(30);
    l_bold        VARCHAR2(30);
    l_italics     VARCHAR2(30);
    l_underline   VARCHAR2(30);
    l_styles      VARCHAR2(255);
    l_formatting  VARCHAR2(10);
    l_result      apex_plugin.t_page_item_render_result;
  BEGIN
    l_formatting := COALESCE(p_item.attribute_01, 'Y');
    IF p_is_readonly OR p_is_printer_friendly THEN
      -- emit hidden textarea if necessary
      apex_plugin_util.print_hidden_if_readonly (
        p_item_name => p_item.name,
        p_value => p_value,
        p_is_readonly => p_is_readonly,
        p_is_printer_friendly => p_is_printer_friendly
      );
      -- emit display span with the value
      apex_plugin_util.print_display_only (
        p_item_name => p_item.name,
        p_display_value => p_value,
        p_show_line_breaks => false,
        p_escape => true,
        p_attributes => p_item.element_attributes
      );
    ELSE
      -- Because the page item saves state, we have to call get_input_name_for_page_item
      -- which generates the internal hidden p_arg_names textarea. It will also RETURN the
      -- HTML textarea name which we have to use when we render the HTML input textarea.
      l_name := apex_plugin.get_input_name_for_page_item(false);
      
      l_code      := apex_lang.lang('Code');
      l_bold      := apex_lang.lang('Bold');
      l_italics   := apex_lang.lang('Italics');
      l_underline := apex_lang.lang('Underline');
      IF l_formatting = 'Y' THEN
        sys.htp.p('<ul class="format-btn">');
        sys.htp.p(
          q'[<li><img onclick="addStyleTag('b',']' || p_item.name || q'[');" ]'
          || 'alt="' || l_bold  || '" '
          || 'title="' || l_bold  || '" '
          || 'src="' || p_plugin.file_prefix || q'[text-bold-20x22.png" /></li>]'
        );
        sys.htp.p(
          q'[<li><img onclick="addStyleTag('i',']' || p_item.name || q'[');" ]'
          || 'alt="' || l_italics ||'" '
          || 'title="' || l_italics ||'" '
          || 'src="' || p_plugin.file_prefix || q'[text-italics-20x22.png" /></li>]'
        );
        sys.htp.p(
          q'[<li><img onclick="addStyleTag('u',']' || p_item.name || q'[');" ]'
          || 'alt="' || l_underline || '" '
          || 'title="' || l_underline || '" '
          || 'src="' || p_plugin.file_prefix || q'[text-underline-20x22.png" /></li>]'
        );
        sys.htp.p(
          q'[<li><img onclick="addStyleTag('code',']' || p_item.name || q'[');" ]'
          || 'alt="' || l_code  || ' " '
          || 'title="' || l_code  || '" '
          || 'src="' || p_plugin.file_prefix || q'[code-20x22.png" /></li>]'
        );
        sys.htp.p('</ul>');
        sys.htp.p(
          '<div>'
          || APEX_ESCAPE.HTML (apex_lang.message('MSG_ALLOWED_HTML_TAGS'))
          || '</div>'
        );
      END IF;
      sys.htp.prn('<textarea '
        || apex_plugin_util.get_element_attributes(p_item, l_name, 'textarea')
        || 'cols="' || p_item.element_width ||'" '
        || 'rows="' || p_item.element_height ||'" '
        || 'maxlength="' || p_item.element_max_length || '">'
      );
      apex_plugin_util.print_escaped_value(p_value);
      sys.htp.p('</textarea>');
      -- Tell APEX that this textarea is navigable
      l_result.is_navigable := true;
    END IF;
    RETURN l_result;
  END render_comment_textarea;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION validate_comment_textarea(
    p_item   IN apex_plugin.t_page_item,
    p_plugin IN apex_plugin.t_plugin,
    p_value  IN VARCHAR2
  ) RETURN apex_plugin.t_page_item_validation_result
  AS
    l_formatting  VARCHAR2(10);
    l_tmp_item    VARCHAR2(30);
    l_comment     XMLTYPE;
    l_is_valid    BOOLEAN;
    l_result      apex_plugin.t_page_item_validation_result;
    xml_parse_err EXCEPTION;
    PRAGMA EXCEPTION_INIT (xml_parse_err , -31011);
  BEGIN
    l_formatting := COALESCE(p_item.attribute_01, 'Y');
    l_tmp_item := p_item.attribute_02;
    blog_plugin.g_formatted_comment := p_value;
    /* Remove some ascii codes */
    FOR i IN 0 .. 31
    LOOP
      IF i != 10 THEN
        blog_plugin.g_formatted_comment := TRIM(REPLACE(blog_plugin.g_formatted_comment, chr(i)));
      END IF;
    END LOOP;
    IF blog_plugin.g_formatted_comment IS NULL THEN
      RETURN NULL;
    END IF;
    IF LENGTH(blog_plugin.g_formatted_comment) >= p_item.element_max_length THEN
      l_is_valid := FALSE;
      l_result.message := apex_lang.message('VALIDATION_COMMENT_LENGTH', p_item.plain_label, p_item.element_max_length);
    ELSE
      l_is_valid := TRUE;
    END IF;
    IF l_is_valid THEN
      /* Format value */
      IF l_formatting = 'Y' THEN
        blog_plugin.g_formatted_comment := blog_plugin.format_comment(blog_plugin.g_formatted_comment, g_whitelist_tags);
      ELSE
        blog_plugin.g_formatted_comment := blog_plugin.format_comment(blog_plugin.g_formatted_comment, NULL);
      END IF;
      /* Validate value html tags */
      BEGIN
        l_comment := xmlType.createXML(
            '<root><row>' 
          || blog_plugin.g_formatted_comment
          || '</row></root>'
        );
      EXCEPTION
      WHEN xml_parse_err THEN
        l_is_valid := FALSE;
        apex_debug.error('%s : %s', sys.dbms_utility.format_error_backtrace, sqlerrm);
      WHEN OTHERS THEN
        apex_debug.error('%s : %s', sys.dbms_utility.format_error_backtrace, sqlerrm);
        l_is_valid := FALSE;
      END;
      IF NOT l_is_valid THEN
        l_is_valid := FALSE;
        l_result.message := apex_lang.message('VALIDATION_COMMENT_FORMAT', p_item.plain_label);
      END IF;
    END IF;
    RETURN l_result;
  END validate_comment_textarea;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION feature_authorization (
    p_authorization in apex_plugin.t_authorization,
    p_plugin        in apex_plugin.t_plugin
  ) RETURN apex_plugin.t_authorization_exec_result
  AS
    l_count         NUMBER;
    l_feature_name  VARCHAR(100);
    l_result        apex_plugin.t_authorization_exec_result; -- result object to RETURN
  BEGIN
    l_feature_name := p_authorization.attribute_01;
    SELECT COUNT(1)
    INTO l_count
    FROM blog_param c
    LEFT JOIN blog_param p ON c.param_parent = p.param_id
    WHERE c.param_id = l_feature_name
      AND c.param_value = 'Y' 
      AND CASE WHEN p.param_type = 'YESNO'
      THEN p.param_value ELSE 'Y' END = 'Y'
    ;
    l_result.is_authorized := l_count > 0;
    RETURN l_result;
END feature_authorization;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_math_question_field(
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    l_name        VARCHAR2(30);
    l_answer_item VARCHAR2(30);
    l_result      apex_plugin.t_page_item_render_result;
  BEGIN
    l_name        := apex_plugin.get_input_name_for_page_item(false);
    l_answer_item := p_item.attribute_01;
    
    IF p_is_readonly OR p_is_printer_friendly THEN
      -- emit hidden textarea if necessary
      apex_plugin_util.print_hidden_if_readonly (
        p_item_name => p_item.name,
        p_value => p_value,
        p_is_readonly => p_is_readonly,
        p_is_printer_friendly => p_is_printer_friendly
      );
      -- emit display span with the value
      apex_plugin_util.print_display_only (
        p_item_name => p_item.name,
        p_display_value => p_value,
        p_show_line_breaks => false,
        p_escape => true,
        p_attributes => p_item.element_attributes
      );
    ELSE
      sys.htp.p('<input type="text" '
        || 'size="' || p_item.element_width ||'" '
        || 'maxlength="' || p_item.element_max_length || '" '
        || apex_plugin_util.get_element_attributes(p_item, l_name, 'text_field')
        || 'value="" />'
      );
      apex_javascript.add_onload_code (
        p_code => 'apex.server.plugin("' || apex_plugin.get_ajax_identifier || '",{},{'
        || 'dataType:"html",'
        || 'success:function(data){'
        || '$("'
        || apex_plugin_util.page_item_names_to_jquery(p_item.name) 
        || '").before(data).siblings("label,br").remove()}'
        || '});'
      );
      -- Tell APEX that this textarea is navigable
      l_result.is_navigable := true;
    END IF;
    RETURN l_result;
  END render_math_question_field;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION ajax_math_question_field(
    p_item   in apex_plugin.t_page_item,
    p_plugin in apex_plugin.t_plugin
  ) RETURN apex_plugin.t_page_item_ajax_result
  AS
    l_tmp         VARCHAR2(255);
    l_answer_item VARCHAR2(30);
    l_min_1       PLS_INTEGER := 1;
    l_max_1       PLS_INTEGER := 1;
    l_min_2       PLS_INTEGER := 1;
    l_max_2       PLS_INTEGER := 1;
    l_arr         apex_application_global.vc_arr2;
    l_result      apex_plugin.t_page_item_ajax_result;
  BEGIN
    l_answer_item := p_item.attribute_01;
    l_min_1       := p_item.attribute_02;
    l_max_1       := p_item.attribute_03;
    l_min_2       := p_item.attribute_04;
    l_max_2       := p_item.attribute_05;
    l_arr(1)      := ROUND(sys.dbms_random.VALUE(l_min_1, l_max_1));
    l_arr(1)      := ROUND(sys.dbms_random.VALUE(l_min_2, l_max_2));
    FOR n IN 1 .. 2
    LOOP
      l_arr(n) := ROUND(sys.dbms_random.VALUE(1, 40));
      FOR i IN 1 .. LENGTH(l_arr(n))
      LOOP
        l_tmp := l_tmp || '&#' || ASCII(SUBSTR(l_arr(n), i, 1));
      END LOOP;
      IF n = 1 THEN
        l_tmp := l_tmp || '&nbsp;&#' || ASCII('+') || '&nbsp;';
      END IF;
    END LOOP;
    -- Write header for the output.
    sys.owa_util.mime_header('text/html', false);
    sys.htp.p('Cache-Control: no-cache');
    sys.htp.p('Pragma: no-cache');
    --sys.htp.p('X-Robots-Tag    noindex,follow');
    sys.owa_util.http_header_close;
    sys.htp.p('<p>' || apex_lang.message('MSG_MATH_QUESTION', '</p><span>' ||l_tmp || '&nbsp;&#' || ASCII('=') || '</span>'));
    /* set correct answer to item session state */
    apex_util.set_session_state(l_answer_item, TO_NUMBER(l_arr(1)) + TO_NUMBER(l_arr(2)));
    RETURN l_result;
  EXCEPTION WHEN OTHERS
  THEN
    sys.htp.prn(wwv_flow_lang.system_message('ajax_server_error'));
    RETURN l_result;
  END ajax_math_question_field;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION validate_math_question_field(
    p_item   IN apex_plugin.t_page_item,
    p_plugin IN apex_plugin.t_plugin,
    p_value  IN VARCHAR2
  ) RETURN apex_plugin.t_page_item_validation_result
  AS
    l_answer_item VARCHAR2(30);
    l_value       SIMPLE_INTEGER := 0;
    l_answer      SIMPLE_INTEGER := 0;
    l_is_valid    BOOLEAN;
    l_result      apex_plugin.t_page_item_validation_result;
  BEGIN
    l_answer_item := p_item.attribute_01;
    IF p_value IS NULL THEN
      RETURN NULL;
    END IF;
    BEGIN
      l_is_valid := TO_NUMBER(p_value) = nv(l_answer_item);
    EXCEPTION WHEN 
    VALUE_ERROR OR 
    INVALID_NUMBER
    THEN
      l_is_valid := FALSE;
    END;
    IF NOT l_is_valid THEN
      l_result.message := apex_lang.message('VALIDATION_MATH_QUESTION', p_item.plain_label);
    END IF;
    RETURN l_result;
  END validate_math_question_field;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_simple_star_rating (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS 
    l_result apex_plugin.t_page_item_render_result;
  BEGIN
    -- Don't show the widget if we are running in printer friendly mode
    if p_is_printer_friendly then
        RETURN null;
    end if;
    sys.htp.prn(
      '<div id="' || p_item.name || '" class="rating" data-val="' || p_value || '">'
      || '<ul>'
    );
    for i in 1 .. 5 loop
        sys.htp.prn(
          '<li id="' || p_item.name ||'_' || i || '" title="' || i || '" '
          || case when l_result.is_navigable then
            case when i <=  p_value then 'class="active enabled"' else 'class="enabled"' end
          else
            case when i <=  p_value then 'class="active"' end
          end
          || '/></li>'
        );
    end loop;
    sys.htp.prn('</ul>');
    if not p_is_readonly then
      apex_javascript.add_onload_code (p_code => '$("'
        || apex_plugin_util.page_item_names_to_jquery(p_item.name) 
        || '").starRating();'
      );
      sys.htp.p(
        '<div id="' || p_item.name ||'_DIALOG" class="hideMe508">'
        || apex_lang.message('DIALOG_ARTICLE_RATED')
        || '</div>'
      );
      apex_javascript.add_3rd_party_library_file (
        p_library   => apex_javascript.c_library_jquery_ui,
        p_file_name => 'jquery.ui.button'
      );
    end if;
    sys.htp.p('</div>');
    -- Tell APEX that this field is NOT navigable
    l_result.is_navigable := false;
    RETURN l_result;
  END render_simple_star_rating;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_modal_confirm(
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin
  ) RETURN apex_plugin.t_dynamic_action_render_result
  AS
    l_result apex_plugin.t_dynamic_action_render_result;
  BEGIN
    apex_javascript.add_inline_code (
      p_code => 'function org_blogsite_jaris_modal_confirm(){'
        || 'this.affectedElements.data("request",this.triggeringElement.id).dialog({'
        || 'modal:true,'
        || 'buttons:{'
        || '"' || apex_lang.lang('OK') || '":function(){$(this).dialog("close");apex.submit($(this).data("request"));},'
        || '"' || apex_lang.lang('Cancel') || '":function(){$(this).dialog("close")}'
        || '}})}'
      ,p_key  => 'org.blogsite.jaris.modal_confirm'
    );
    apex_javascript.add_3rd_party_library_file (
      p_library   => apex_javascript.c_library_jquery_ui,
      p_file_name => 'jquery.ui.button'
    );
    l_result.javascript_function := 'org_blogsite_jaris_modal_confirm';
    RETURN l_result;
  END render_modal_confirm;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_google_plus_one_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    c_host constant varchar2(4000) := apex_util.host_url('SCRIPT');
    
    -- It's better to have named variables instead of using the generic ones,
    -- makes the code more readable.
    -- We are using the same defaults for the required attributes as in the
    -- plug-in attribute configuration, because they can still be null.
    -- Note: Keep them in sync!
    l_url_to_plus varchar2(20)    := coalesce(p_item.attribute_01, 'current_page');
    l_page_url    varchar2(4000)  := p_item.attribute_02;
    l_custom_url  varchar2(4000)  := p_item.attribute_03;
    l_size        varchar2(20)    := coalesce(p_item.attribute_04, 'standard');
    l_annotation  varchar2(20)    := coalesce(p_item.attribute_05, 'bubble');
    l_width       varchar2(256)   := p_item.attribute_06;
    l_align       varchar2(20)    := coalesce(p_item.attribute_07, 'left');
    l_expandto    varchar2(100)   := p_item.attribute_08;
    
    l_url             varchar2(4000);
    l_result          apex_plugin.t_page_item_render_result;
  BEGIN
    -- Don't show the widget if we are running in printer friendly mode
    if p_is_printer_friendly then
        RETURN null;
    end if;
    
    -- Generate the Google +1 URL based on our URL setting.
    -- Note: Always use session 0, otherwise Google +1 will always register a different URL.
    l_url := case l_url_to_plus
               when 'current_page' then c_host || 'f?p=' || apex_application.g_flow_id || ':' || apex_application.g_flow_step_id || ':0'
               when 'page_url'     then c_host||l_page_url
               when 'custom_url'   then replace(l_custom_url, '#HOST#', c_host)
               when 'value'        then replace(p_value, '#HOST#', c_host)
             end;
    -- Output the Google +1 button widget
    -- See https://developers.google.com/+/web/+1button/ for syntax
    sys.htp.prn (
      '<script src="https://apis.google.com/js/platform.js" async defer></script>' ||
      ''
      || '<div class="g-plusone"'
      || ' data-href="' || l_url || '"'
      || ' data-size="' || apex_escape.html_attribute(l_size) || '"'
      || ' data-annotation="' || apex_escape.html_attribute(l_annotation) || '"'
      || case when l_annotation = 'inline' then
          ' data-width="' || apex_escape.html_attribute(l_annotation) || '"'
         end
      || ' data-align="' || apex_escape.html_attribute(l_align) || '"'
      || ' data-expandTo="' || apex_escape.html_attribute(replace(l_expandto, ':', ',')) || '"'
      || '></div>'
    );
    -- Tell APEX that this field is NOT navigable
    l_result.is_navigable := false;
    RETURN l_result;
  END render_google_plus_one_button;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  FUNCTION render_google_share_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    c_host constant varchar2(4000) := apex_util.host_url('SCRIPT');
    
    -- It's better to have named variables instead of using the generic ones,
    -- makes the code more readable.
    -- We are using the same defaults for the required attributes as in the
    -- plug-in attribute configuration, because they can still be null.
    -- Note: Keep them in sync!
    l_url_to_plus varchar2(20)    := coalesce(p_item.attribute_01, 'current_page');
    l_page_url    varchar2(4000)  := p_item.attribute_02;
    l_custom_url  varchar2(4000)  := p_item.attribute_03;
    l_annotation  varchar2(20)    := coalesce(p_item.attribute_04, 'bubble');
    l_width       varchar2(256)   := p_item.attribute_05;
    l_height      varchar2(256)   := coalesce(p_item.attribute_06, '20');
    l_align       varchar2(20)    := coalesce(p_item.attribute_07, 'left');
    l_expandto    varchar2(100)   := p_item.attribute_08;
    
    l_url             varchar2(4000);
    l_result          apex_plugin.t_page_item_render_result;
  BEGIN
    -- Don't show the widget if we are running in printer friendly mode
    if p_is_printer_friendly then
        RETURN null;
    end if;
    
    -- Generate the Google Share based on our URL setting.
    -- Note: Always use session 0, otherwise Google Share will always register a different URL.
    l_url := case l_url_to_plus
               when 'current_page' then c_host || 'f?p=' || apex_application.g_flow_id || ':' || apex_application.g_flow_step_id || ':0'
               when 'page_url'     then c_host||l_page_url
               when 'custom_url'   then replace(l_custom_url, '#HOST#', c_host)
               when 'value'        then replace(p_value, '#HOST#', c_host)
             end;
    -- Output the Google Share button widget
    -- See https://developers.google.com/+/web/+1button/ for syntax
    sys.htp.prn (
      '<script src="https://apis.google.com/js/platform.js" async defer></script>' ||
      ''
      || '<div class="g-plus" data-action="share"'
      || ' data-href="' || l_url || '"'
      || ' data-annotation="' || apex_escape.html_attribute(l_annotation) || '"'
      || ' data-width="' || apex_escape.html_attribute(l_annotation) || '"'
      || ' data-height="' || apex_escape.html_attribute(l_height) || '"'
      || ' data-align="' || apex_escape.html_attribute(l_align) || '"'
      || ' data-expandTo="' || apex_escape.html_attribute(replace(l_expandto, ':', ',')) || '"'
      || '></div>'
    );
    -- Tell APEX that this field is NOT navigable
    l_result.is_navigable := false;
    RETURN l_result;
  END render_google_share_button;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--==============================================================================
-- Renders the Facebook "Like" button widget based on the configuration of the
-- page item.
--==============================================================================
  FUNCTION render_facebook_like_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    c_host constant varchar2(4000) := apex_util.host_url('SCRIPT');
    
    -- It's better to have named variables instead of using the generic ones,
    -- makes the code more readable.
    -- We are using the same defaults for the required attributes as in the
    -- plug-in attribute configuration, because they can still be null.
    -- Note: Keep them in sync!
    l_url_to_like  varchar2(20)   := nvl(p_item.attribute_01, 'current_page');
    l_page_url     varchar2(4000) := p_item.attribute_02;
    l_custom_url   varchar2(4000) := p_item.attribute_03;
    l_layout_style varchar2(15)   := nvl(p_item.attribute_04, 'standard');
    l_show_faces   boolean        := (nvl(p_item.attribute_05, 'Y') = 'Y');
    l_width        number         := p_item.attribute_06;
    l_verb         varchar2(15)   := nvl(p_item.attribute_07, 'like');
    l_font         varchar2(15)   := p_item.attribute_08;
    l_color_scheme varchar2(15)   := nvl(p_item.attribute_09, 'light');
    
    l_url          varchar2(4000);
    l_height       number;
    l_result       apex_plugin.t_page_item_render_result;
  BEGIN
    -- Don't show the widget if we are running in printer friendly mode
    if p_is_printer_friendly then
        RETURN null;
    end if;
      
    -- Get the width and the height depending on the picked layout style
    if l_width is null then
        l_width := case l_layout_style
                     when 'standard'     then 450
                     when 'button_count' then 90
                     when 'box_count'    then 55
                   end;
    end if;
    
    l_height := case l_layout_style
                  when 'standard'     then case when l_show_faces then 80 else 35 end
                  when 'button_count' then 20
                  when 'box_count'    then 65
                end;
    -- Base URL for the "Like" widget.
    -- See http://developers.facebook.com/docs/reference/plugins/like
    -- for a documentation of the URL syntax
    l_url := '//www.facebook.com/plugins/like.php?href=';
    
    -- Generate the "Like" URL based on our URL to Like setting.
    -- Note: Always use session 0, otherwise Facebook will not be able to get the page.
    l_url := l_url||
             utl_url.escape (
                 url => case l_url_to_like
                          when 'current_page' then c_host||'f?p='||apex_application.g_flow_id||':'||apex_application.g_flow_step_id||':0'
                          when 'page_url'     then c_host||l_page_url
                          when 'custom_url'   then replace(l_custom_url, '#HOST#', c_host)
                          when 'value'        then replace(p_value, '#HOST#', c_host)
                        end,
                 escape_reserved_chars => true)||
             '&amp;';
    -- Add the display options for the "Like" button widget
    l_url := l_url||
             'layout='||l_layout_style||'&amp;'||
             case when l_layout_style = 'standard' then
                 'show_faces='||case when l_show_faces then 'true' else 'false' end||'&amp;'
             end||
             'width='||l_width||'&amp;'||
             'action='||l_verb||'&amp;'||
             case when l_font is not null then 'font='||l_font||'&amp;' end||
             'colorscheme='||l_color_scheme||'&amp;'||
             'height='||l_height;
    -- Output the Facebook Like button widget
    sys.htp.prn('<iframe src="'||l_url||'" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:'||l_width||'px; height:'||l_height||'px;" allowTransparency="true"></iframe>');
    -- Tell APEX that this field is NOT navigable
    l_result.is_navigable := false;
    RETURN l_result;
  END render_facebook_like_button;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--==============================================================================
-- Renders the Twitter button widget based on the configuration of the
-- page item.
--==============================================================================
  FUNCTION render_twitter_button (
    p_item                IN apex_plugin.t_page_item,
    p_plugin              IN apex_plugin.t_plugin,
    p_value               IN VARCHAR2,
    p_is_readonly         IN BOOLEAN,
    p_is_printer_friendly IN BOOLEAN
  ) RETURN apex_plugin.t_page_item_render_result
  AS
    c_host constant varchar2(4000) := apex_util.host_url('SCRIPT');
    
    -- It's better to have named variables instead of using the generic ones,
    -- makes the code more readable.
    -- We are using the same defaults for the required attributes as in the
    -- plug-in attribute configuration, because they can still be null.
    -- Note: Keep them in sync!
    l_url_to_like     varchar2(20)   := nvl(p_item.attribute_01, 'current_page');
    l_page_url        varchar2(4000) := p_item.attribute_02;
    l_custom_url      varchar2(4000) := p_item.attribute_03;
    l_layout_style    varchar2(15)   := nvl(p_item.attribute_04, 'vertical');
    l_tweet_text_type varchar2(10)   := nvl(p_item.attribute_05, 'page_title');
    l_custom_text     varchar2(140)  := sys.htf.escape_sc(p_item.attribute_06);
    l_follow1         varchar2(4000) := sys.htf.escape_sc(p_item.attribute_07);
    l_follow2         varchar2(4000) := sys.htf.escape_sc(p_item.attribute_08);
    
    l_url             varchar2(4000);
    l_result          apex_plugin.t_page_item_render_result;
  BEGIN
    -- Don't show the widget if we are running in printer friendly mode
    if p_is_printer_friendly then
        RETURN null;
    end if;
    
    -- Generate the Tweet URL based on our URL setting.
    -- Note: Always use session 0, otherwise Twitter will always register a different URL.
    l_url := case l_url_to_like
               when 'current_page' then c_host||'f?p='||apex_application.g_flow_id||':'||apex_application.g_flow_step_id||':0'
               when 'page_url'     then c_host||l_page_url
               when 'custom_url'   then replace(l_custom_url, '#HOST#', c_host)
               when 'value'        then replace(p_value, '#HOST#', c_host)
             end;
    -- For a custom text we have to replace the #PAGE_TITLE# placeholder with the correct
    -- language dependent page title of the current page.
    if l_tweet_text_type = 'custom' then
        if instr(l_custom_text, '#PAGE_TITLE') > 0 then
            select replace(l_custom_text, '#PAGE_TITLE#', apex_application.do_substitutions(page_title, 'ESC'))
              into l_custom_text
              from apex_application_pages
             where application_id = nvl(apex_application.g_translated_flow_id, apex_application.g_flow_id)
               and page_id        = nvl(apex_application.g_translated_page_id, apex_application.g_flow_step_id);
        end if;
    end if;
    -- Output the Twitter button widget
    -- See http://twitter.com/about/resources/tweetbutton for syntax
    sys.htp.prn (
        '<a href="//twitter.com/share" class="twitter-share-button" data-url="'||sys.htf.escape_sc(l_url)||'" '||
        case when l_tweet_text_type = 'custom' then 'data-text="'||l_custom_text||'" ' end||
        'data-count="'||l_layout_style||'" '||
        case when l_follow1 is not null then 'data-via="'||l_follow1||'" ' end||
        case when l_follow2 is not null then 'data-related="'||l_follow2||'" ' end||
        '>Tweet</a><script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>' );
    -- Tell APEX that this field is NOT navigable
    l_result.is_navigable := false;
    RETURN l_result;
  END render_twitter_button;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_PLUGIN";
/