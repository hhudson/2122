create or replace PACKAGE BODY  "BLOG_XML" 
AS
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
  PROCEDURE rss(
    p_app_alias IN VARCHAR2,
    p_blog_name IN VARCHAR2,
    p_base_url  IN VARCHAR2
  )
  AS
    l_xml         BLOB;
    l_url         VARCHAR2(255);
    l_rss_desc    VARCHAR2(255);
    l_rss_url     VARCHAR2(255);
    l_home_url    VARCHAR2(255);
    l_article_url VARCHAR2(255);
    l_webmaster   VARCHAR2(255);
    l_rss_lang    VARCHAR2(5);
    c_version     CONSTANT VARCHAR2(5) := '2.0';
  BEGIN
    l_rss_lang    := apex_application.g_browser_language;
    l_rss_desc    := apex_plugin_util.replace_substitutions(apex_lang.message('RSS_DESCRIPTION'));
    
    l_url         := 'f?p=' || p_app_alias || ':';
    l_rss_url     := p_base_url || l_url || 'RSS';
    l_home_url    := p_base_url || l_url || 'HOME';
    l_article_url := l_url || 'READ:0::::ARTICLE:';
    SELECT xmlelement("rss", xmlattributes(c_version AS "version", 'http://www.w3.org/2005/Atom' AS "xmlns:atom", 'http://purl.org/dc/elements/1.1/' AS "xmlns:dc"),
      xmlelement("channel",
        xmlelement("atom:link", xmlattributes(l_rss_url AS "href", 'self' AS "rel", 'application/rss+xml' AS "type")),
        xmlforest(
          p_blog_name AS "title"
          ,l_home_url AS "link"
          ,l_rss_desc AS "description"
          ,l_rss_lang AS "language"
        ),
        xmlagg(
          xmlelement("item",
            xmlelement("title", l.rss_title),
            xmlelement("dc:creator", l.posted_by),
            xmlelement("category", l.rss_category),
            xmlelement("link", p_base_url || apex_util.prepare_url(l_article_url || l.article_id, NULL, 'PUBLIC_BOOKMARK')),
            xmlelement("description", l.rss_description),
            xmlelement("pubDate", l.rss_pubdate),
            xmlelement("guid", xmlattributes('false' AS "isPermaLink"), l.rss_guid)
          ) ORDER BY created_on DESC
        )
      )
    ).getblobval(nls_charset_id('AL32UTF8'))
    INTO l_xml
    FROM blog_article_last20 l
    ;
	sys.htp.flush;
	sys.htp.init;
    owa_util.mime_header('application/rss+xml', TRUE);
    wpg_docload.download_file(l_xml);
    apex_application.stop_apex_engine;
  END rss;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  PROCEDURE sitemap(
    p_app_id    IN NUMBER,
    p_app_alias IN VARCHAR2,
    p_base_url  IN VARCHAR2,
    p_tab_list  IN VARCHAR2
  )
  AS
    l_xml             BLOB;
    l_article_url     VARCHAR2(255);
    l_category_url    VARCHAR2(255);
  BEGIN
    l_article_url   := 'f?p=' || p_app_alias || ':READ:0::::ARTICLE:';
    l_category_url  := 'f?p=' || p_app_alias || ':READCAT:0::::CATEGORY:';
    WITH article_cat AS(
      SELECT category_id,
        MAX(changed_on) AS changed_on
      FROM blog_v$article b
      GROUP BY category_id
    ), sitemap_query AS (
      SELECT 1 AS grp,
        ROW_NUMBER() OVER(ORDER BY e.display_sequence) AS rnum,
        apex_plugin_util.replace_substitutions(e.entry_target) AS url,
        (SELECT MAX(changed_on) FROM article_cat) AS lastmod
      FROM APEX_APPLICATION_LIST_ENTRIES e
      WHERE e.application_id = p_app_id
        AND e.list_name      = p_tab_list
        AND
          blog_xml.show_entry(
            (SELECT o.build_option_id FROM apex_application_build_options o WHERE o.build_option_name = e.build_option),
            e.authorization_scheme_id,
            e.condition_type_code,
            e.condition_expression1,
            e.condition_expression2
           ) = 'true'
      UNION ALL
      SELECT 2 AS grp,
        ROW_NUMBER() OVER(ORDER BY a.created_on) AS rnum,
        apex_util.prepare_url(l_article_url || a.article_id, NULL, 'PUBLIC_BOOKMARK') AS url,
        a.changed_on AS lastmod
      FROM blog_v$article a
      UNION ALL
      SELECT 3 AS grp,
        ROW_NUMBER() OVER(ORDER BY c.category_seq) AS rnum,
        apex_util.prepare_url(l_category_url || c.category_id, NULL, 'PUBLIC_BOOKMARK') AS url,
        a.changed_on AS lastmod
      FROM blog_category c
      JOIN article_cat a
        ON c.category_id = a.category_id
       AND c.active = 'Y'
    )
    SELECT XMLElement("urlset", XMLAttributes('http://www.sitemaps.org/schemas/sitemap/0.9' AS "xmlns"),
        (
          XMLAgg(
              XMLElement("url"
              ,XMLElement("loc", p_base_url || url)
              ,XMLElement("lastmod", TO_CHAR(lastmod, 'YYYY-MM-DD'))
              ,XMLElement("changefreq", 'monthly')
              ,XMLElement("priority", '0.5')
            ) ORDER BY grp,rnum
          )
        )
      ).getblobval(nls_charset_id('AL32UTF8'))
    INTO l_xml
    FROM sitemap_query
    ;
	sys.htp.flush;
	sys.htp.init;
    owa_util.mime_header('application/xml', TRUE);
    wpg_docload.download_file(l_xml);
    apex_application.stop_apex_engine;
  END sitemap;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
END "BLOG_XML";
/
