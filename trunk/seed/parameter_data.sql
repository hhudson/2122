--REM INSERTING into BLOG_PARAM
--SET DEFINE OFF;
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('ADMIN_VERSION','N','Blog admin application version id','a2.9.0.2','Used on future releases for upgrade. Only for developers.','TEXT','N','INTERNAL','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('ALLOW_COMMENT','Y','Allow comments','Y','If set to "<b>Yes</b>", readers can post comments to any article.','YESNO','N','COMMENT','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('BLOG_EMAIL','Y','Blog email','blog@example.com','Email address witch is used notification emails from field.','TEXT','Y','EMAIL','B','NOTIFICATION_EMAIL_ENABLED');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('COMMENT_VERIFY_QUESTION','Y','Show math question','Y','If set to "<b>Yes</b>", small math question is displayed in comment and contact page.<br/>This <b>might</b> prevent bots posting comments to articles.','YESNO','N','COMMENT','B','ALLOW_COMMENT');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('FACEBOOK_BTN_ENABLED','Y','Facebook like button','Y','If set to "<b>Yes</b>", Facebook like button is shown on article page.','YESNO','N','COMMENT','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('FILE_DOWNLOAD_ENABLED','Y','Allow file download','Y','If set to "<b>Yes</b>", access to file repository URL for downloads is allowed.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_ARTICLE_ROWS','Y','Article per pagination','3','How many articles is shown per pagination e.g. in blog home page.','NUMBER','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_BASE_URL','Y','Canonical URL','http://vbox-apex/apex/','Canonical URL is useful to solve www and non-www duplicate content where two URLs,<br/>identical except that one begins with "www" and other does not, point to the same page.','TEXT','N','SEO','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_BLOG_ADMIN_APP_ID','N','Blog admin application id','291','Only for developers.','NUMBER','N','INTERNAL','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_BLOG_NAME','Y','Blog name','My Blog','Blog name displayed in blog reader.','TEXT','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_BLOG_READER_APP_ID','N','Blog reader application id','290','Only for developers.','NUMBER','N','INTERNAL','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_COMMENT_ROWS','Y','Comments per pagination','10','How many comments is shown per pagination e.g. in blog article page.','NUMBER','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_DATE_FORMAT','Y','Date format','fmDD Mon YYYY','Blog reader date format used e.g. when article is posted.','TEXT','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_HTML_HEADER','Y','Extra HTML header attributes',null,'You can enter e.g. extra meta tags and JavaScript for HTML header.<br/>Common use is place e.g. Google Analytic JavaScript and/or Google webmaster verification meta tag here.<br/><br/>All what you enter here are included to HTML header as is.<br/>For e.g. Google Analytic JavaScript include also &lt;script&gt; tags and Google webmaster verification place whole meta tag.','TEXTAREA','Y','SEO','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('GOOGLE_PLUS_ONE_BTN_ENABLED','Y','Google +1 button','Y','If set to "<b>Yes</b>", Google +1 button is shown on article page.','YESNO','N','COMMENT','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('GOOGLE_SHARE_BTN_ENABLED','Y','Google Share button','Y','If set to "<b>Yes</b>", Google Share button is shown on article page.','YESNO','N','COMMENT','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_RSS_FEED_URL','Y','RSS feed URL','http://vbox-apex/apex/f?p=BLOG:RSS','Blog RSS feed URL. Default is &G_BASE_URL.f?p=&lt;blog application alias&gt;:RSS.<br/>Tip: You can "burn" blog feed in <a target="blank" href="http://feedburner.google.com">Feedburner</a> and use burned feed full URL here.','TEXT','Y','RSS','B','RSS_FEED_ENABLED');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('G_THEME_PATH','Y','Theme location','f?p=290:DOWNLOAD:0:','HTTP server folder where theme is located.','TEXT','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('LOGGING_ENABLED','Y','Log activity','Y','If set to "<b>Yes</b>", new sessions, article access, category access and users search are logged.<br/>Setting this to "<b>No</b>" <u>may</u> increase performance.','YESNO','N','LOG','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('LOG_ROTATE_DAY','N','Rotate log after days','14','Logs rotate interval for application logs. This preference do not affect APEX engine logs.<br/>Currently only developer can change this attribute and it do affect only when blog is installed.<br/>Changing this already installed blog don''t have any affect.','NUMBER','N','LOG','A','LOGGING_ENABLED');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('MODERATION_ENABLED','Y','Moderate comments','Y','If set to "<b>Yes</b>", all comments must be moderated and approved by blog author(s).','YESNO','N','COMMENT','B','ALLOW_COMMENT');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('NOTIFICATION_EMAIL_ENABLED','Y','Send notification emails','Y','If set to "<b>Yes</b>", notification emails are send when new comment is posted.<br/>Set to "<b>No</b>" if you do not have SMTP server configured.','YESNO','N','EMAIL','B','ALLOW_COMMENT');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('RATING_ENABLED','Y','Rate article','Y','If set to "<b>Yes</b>", rating is shown on article page and users can rate article.','YESNO','N','COMMENT','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('READER_VERSION','N','Blog reader application version id','r2.9.0.2','Used on future releases for upgrade. Only for developers.','TEXT','N','INTERNAL','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('RSS_FEED_ENABLED','Y','Publish RSS feed','Y','If set to "<b>Yes</b>", RSS fead is published on URL &G_BASE_URL.f?p=&G_BLOG_READER_APP_ALIAS.:RSS.<br/>Also RSS feed logo is shown in blog reader global page.','YESNO','N','RSS','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SCHEMA_VERSION','N','Blog engine version id','s2.9.0.2','Used on future releases for upgrade. Only for developers.','TEXT','N','INTERNAL','A',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_ABOUT_PAGE','Y','Show about page/tab','Y','If set to "<b>Yes</b>", about page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_AUTHOR_PAGE','Y','Show authors tab/page','Y','If set to "<b>Yes</b>", authors page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_BLOG_DESCRIPTION','Y','Show blog description','Y','If set to "<b>Yes</b>", blog description is visible in blog reader pages under blog name.','YESNO','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_BLOG_REPORT','Y','Show blogroll','Y','If set to "<b>Yes</b>", blogroll list is shown on blog reader resource page.','YESNO','N','AUTH','B','SHOW_RESOURCE_PAGE');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_CONTACT_PAGE','N','Show contact form tab/page','N','If set to "<b>Yes</b>", contact form page can be accessed from blog reader.<br/><br/>!!! DO NOT USE. FEATURE NOT IMPLEMENTED !!!','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_DISCLAIMER_PAGE','Y','Show disclaimer page/tab','Y','If set to "<b>Yes</b>", disclaimer page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_FAQ_PAGE','Y','Show FAQ tab/page','Y','If set to "<b>Yes</b>", frequently asked questions (FAQ) page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_FILE_PAGE','Y','Show files tab/page','Y','If set to "<b>Yes</b>", files page can be accessed from blog reader.','YESNO','N','AUTH','B','FILE_DOWNLOAD_ENABLED');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_FOOTER','Y','Show footer text','Y','If set to "<b>Yes</b>", footer text is shown in every blog reader page.<br/>Foter text is maintained from settings -> messages (BLOG_READER_FOOTER).','YESNO','N','UI','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_PHOTOS_PAGE','Y','Show photos tab/page','Y','If set to "<b>Yes</b>", files page can be accessed from blog reader.','YESNO','N','AUTH','B','FILE_DOWNLOAD_ENABLED');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_RESOURCE_PAGE','Y','Show resources page/tab','Y','If set to "<b>Yes</b>", resources page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_RESOURCE_REPORT','Y','Show useful links','Y','If set to "<b>Yes</b>", useful links list is shown on blog reader resource page.','YESNO','N','AUTH','B','SHOW_RESOURCE_PAGE');
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SHOW_VISITOR_PAGE','Y','Show visitor page/tab','Y','If set to "<b>Yes</b>", visitors map page can be accessed from blog reader.','YESNO','N','AUTH','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('SITEMAP_ENABLED','Y','Publish sitemap','Y','If set to "<b>Yes</b>", sitemap is published on URL &G_BASE_URL.f?p=&G_BLOG_READER_APP_ALIAS.:SITEMAP.','YESNO','N','SEO','B',null);
Insert into BLOG_PARAM (PARAM_ID,EDITABLE,PARAM_NAME,PARAM_VALUE,PARAM_HELP,PARAM_TYPE,PARAM_NULLABLE,PARAM_GROUP,PARAM_USE_SKILL,PARAM_PARENT) values ('TWEET_BTN_ENABLED','Y','Twitter button','Y','If set to "<b>Yes</b>", Twitter button is shown on article page.','YESNO','N','COMMENT','B',null);

