CREATE INDEX  "BLOG_AUTHOR_IDX1" ON  "BLOG_AUTHOR" ("ACTIVE")
/
CREATE INDEX  "BLOG_CATEGORY_IDX1" ON  "BLOG_CATEGORY" ("ACTIVE")
/
CREATE INDEX  "BLOG_COMMENT_BLOCK_IDX1" ON  "BLOG_COMMENT_BLOCK" ("ACTIVE")
/
CREATE INDEX  "BLOG_COMMENT_IDX1" ON  "BLOG_COMMENT" ("USER_ID")
/
CREATE INDEX  "BLOG_COMMENT_IDX2" ON  "BLOG_COMMENT" ("PAGE_ID")
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
CREATE INDEX  "BLOG_PARAM_IDX1" ON  "BLOG_PARAM" ("PARAM_PARENT")
/