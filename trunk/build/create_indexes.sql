CREATE INDEX  "BLOG_ARTICLE_CTX" ON  "BLOG_ARTICLE" ("ARTICLE_TEXT") 
INDEXTYPE IS "CTXSYS"."CONTEXT"  PARAMETERS ('FILTER CTXSYS.NULL_FILTER SECTION GROUP CTXSYS.HTML_SECTION_GROUP SYNC (ON COMMIT)')
/
CREATE INDEX  "BLOG_ARTICLE_IDX1" ON  "BLOG_ARTICLE" ("AUTHOR_ID")
/
CREATE INDEX  "BLOG_ARTICLE_IDX2" ON  "BLOG_ARTICLE" ("CATEGORY_ID")
/
CREATE INDEX  "BLOG_ARTICLE_IDX3" ON  "BLOG_ARTICLE" ("ACTIVE")
/
CREATE INDEX  "BLOG_ARTICLE_IDX4" ON  "BLOG_ARTICLE" ("YEAR_MONTH_NUM")
/
CREATE INDEX  "BLOG_ARTICLE_IDX5" ON  "BLOG_ARTICLE" ("CREATED_ON")
/
CREATE INDEX  "BLOG_ARTICLE_IDX6" ON  "BLOG_ARTICLE" ("VALID_FROM")
/
CREATE INDEX  "BLOG_AUTHOR_IDX1" ON  "BLOG_AUTHOR" ("ACTIVE")
/
CREATE INDEX  "BLOG_CATEGORY_IDX1" ON  "BLOG_CATEGORY" ("ACTIVE")
/
CREATE INDEX  "BLOG_COMMENT_BLOCK_IDX1" ON  "BLOG_COMMENT_BLOCK" ("ACTIVE")
/
CREATE INDEX  "BLOG_COMMENT_IDX1" ON  "BLOG_COMMENT" ("USER_ID")
/
CREATE INDEX  "BLOG_COMMENT_IDX2" ON  "BLOG_COMMENT" ("ARTICLE_ID")
/
CREATE INDEX  "BLOG_COMMENT_IDX3" ON  "BLOG_COMMENT" ("PARENT_ID")
/
CREATE INDEX  "BLOG_COMMENT_IDX4" ON  "BLOG_COMMENT" ("ACTIVE")
/
CREATE INDEX  "BLOG_COMMENT_IDX5" ON  "BLOG_COMMENT" ("MODERATED")
/
CREATE INDEX  "BLOG_COMMENT_IDX6" ON  "BLOG_COMMENT" ("CREATED_ON" DESC)
/
CREATE INDEX  "BLOG_COMMENT_NOTIFY_IDX1" ON  "BLOG_COMMENT_NOTIFY" ("FOLLOWUP_NOTIFY")
/
CREATE INDEX  "BLOG_COMMENT_USER_IDX1" ON  "BLOG_COMMENT_USER" ("BLOCKED")
/
CREATE INDEX  "BLOG_COUNTRY_IDX1" ON  "BLOG_COUNTRY" ("COUNTRY_NAME")
/
CREATE INDEX  "BLOG_COUNTRY_IDX2" ON  "BLOG_COUNTRY" ("VISIT_COUNT")
/
CREATE INDEX  "BLOG_FAQ_IDX1" ON  "BLOG_FAQ" ("ACTIVE")
/
CREATE INDEX  "BLOG_FILE_IDX1" ON  "BLOG_FILE" ("ACTIVE")
/
CREATE INDEX  "BLOG_FILE_IDX2" ON  "BLOG_FILE" ("FILE_TYPE")
/
CREATE INDEX  "BLOG_PARAM_IDX1" ON  "BLOG_PARAM" ("PARAM_PARENT")
/
CREATE INDEX  "BLOG_RESOURCE_IDX1" ON  "BLOG_RESOURCE" ("LINK_TYPE")
/
CREATE INDEX  "BLOG_RESOURCE_IDX2" ON  "BLOG_RESOURCE" ("ACTIVE")
/
