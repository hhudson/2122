--------------------------------------------------------------
--------------------------------------------------------------
CREATE MATERIALIZED VIEW blog_param_app
  NOLOGGING
  BUILD IMMEDIATE
  USING NO INDEX
  REFRESH COMPLETE ON DEMAND
AS
SELECT a.application_id
  ,a.item_name AS param_id
FROM apex_application_items a
WHERE EXISTS (SELECT 1 FROM blog_param p WHERE p.param_id = a.item_name)
/
ALTER TABLE BLOG_PARAM_APP ADD CONSTRAINT BLOG_PARAM_APP_PK PRIMARY KEY (APPLICATION_ID, PARAM_ID)
/
--------------------------------------------------------------
--------------------------------------------------------------
CREATE MATERIALIZED VIEW blog_comment_log
  NOLOGGING
  BUILD IMMEDIATE
  USING NO INDEX
  REFRESH COMPLETE ON DEMAND
AS
SELECT c.PAGE_id,
  COUNT(1) AS total_comment_count,
  SUM(CASE WHEN c.moderated = 'Y' AND c.active = 'Y' THEN 1 ELSE 0 END) AS comment_count,
  MAX(CASE WHEN c.moderated = 'Y' AND c.active = 'Y' THEN c.created_on END) AS last_comment,
  SUM(CASE WHEN c.moderated = 'Y' THEN 1 ELSE 0 END) AS moderated_comment_count,
  MAX(CASE WHEN c.moderated = 'Y' THEN c.created_on END) AS last_moderated_comment,
  SUM(CASE WHEN c.active = 'Y' THEN 1 ELSE 0 END) AS active_comment_count,
  MAX(CASE WHEN c.active = 'Y' THEN c.created_on END) AS last_active_comment
FROM blog_comment c
GROUP BY c.PAGE_id
/
ALTER TABLE BLOG_COMMENT_LOG ADD CONSTRAINT BLOG_COMMENT_LOG_PK PRIMARY KEY (PAGE_ID)
/
ALTER TABLE BLOG_COMMENT_LOG MODIFY TOTAL_COMMENT_COUNT NOT NULL
/
ALTER TABLE BLOG_COMMENT_LOG MODIFY COMMENT_COUNT NOT NULL
/
ALTER TABLE BLOG_COMMENT_LOG MODIFY MODERATED_COMMENT_COUNT NOT NULL
/
ALTER TABLE BLOG_COMMENT_LOG MODIFY ACTIVE_COMMENT_COUNT NOT NULL
/
--------------------------------------------------------------
--------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW blog_v$activity_log
AS 
  SELECT
    activity_date ,
    activity_type,
    apex_session_id,
    ip_address,
    related_id,
    user_id,
    latitude,
    longitude,
    country_code,
    country_region,
    country_city,
    http_user_agent,
    http_referer,
    search_type,
    search_criteria,
	additional_info
FROM blog_activity_log1
UNION ALL
SELECT
    activity_date,
    activity_type,
    apex_session_id,
    ip_address,
    related_id,
    user_id,
    latitude,
    longitude,
    country_code,
    country_region,
    country_city,
    http_user_agent,
    http_referer,
    search_type,
    search_criteria,
	additional_info
FROM blog_activity_log2
WITH READ ONLY CONSTRAINT blog_v$activity_log_ro
/
--------------------------------------------------------------
--------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW blog_v$activity
AS 
  SELECT l.activity_date
  ,l.activity_type
  ,n.apex_session_id
  ,n.ip_address
  ,l.related_id
  ,l.user_id
  ,u.email
  ,u.nick_name
  ,u.website
  ,n.latitude
  ,n.longitude
  ,n.country_code
  ,c.country_name
  ,n.country_region
  ,n.country_city
  ,n.http_user_agent
  ,l.http_referer
  ,l.search_type
  ,l.search_criteria
  ,l.additional_info
FROM blog_v$activity_log l
JOIN blog_v$activity_log n
  ON l.apex_session_id = n.apex_session_id
 AND n.activity_type = 'NEW_SESSION'
LEFT JOIN blog_country c 
  ON n.country_code = c.country_code
LEFT JOIN blog_comment_user u
  ON l.user_id = u.user_id
WITH READ ONLY CONSTRAINT blog_v$activity_ro
/
--------------------------------------------------------------
--------------------------------------------------------------