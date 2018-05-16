@trunk/build/create_tables.sql;
@trunk/build/create_indexes.sql;
@trunk/sequences/blog_seq.sql;
@trunk/build/create_synonyms.sql;
@trunk/build/functions.sql;
@trunk/build/create_views.sql;
@trunk/packages/blog_log_pkg.pks;
@trunk/packages/blog_log_pkg.pkb;
@trunk/packages/blog_xml_pkg.pks;
@trunk/packages/blog_xml_pkg.pkb;
@trunk/packages/blog_util_pkg.pks;
@trunk/packages/blog_util_pkg.pkb;
@trunk/packages/blog_plugin_pkg.pks;
@trunk/packages/blog_plugin_pkg.pkb;
@trunk/packages/blog_job_pkg.pks;
@trunk/packages/blog_job_pkg.pkb;
@trunk/packages/blog_install_pkg.pks;
@trunk/packages/blog_install_pkg.pkb;
@trunk/packages/blog_admin_app_pkg.pks;
@trunk/packages/blog_admin_app_pkg.pkb;
@trunk/build/triggers.sql;
@trunk/seed/parameter_data.sql;
@trunk/seed/country_data.sql;
@trunk/seed/admin.sql;
@trunk/seed/long.sql;
@trunk/build/fk.sql;
@trunk/seed/theme_files.sql; errors
/
update blog_author 
set user_name = 'HAYDEN',
    passwd = blog_pw_hash('HAYDEN', 'Oradoc_db1');
/
BEGIN
  blog_install.set_jobs;
  blog_install.update_param_data;
END;
/
@trunk/apex/f209021.sql;
@trunk/apex/f427.sql;