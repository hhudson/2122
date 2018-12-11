@initial_setup/prereqs.sql;
@source/build/create_tables.sql;
@source/build/create_types.sql;
@source/build/create_indexes.sql;
@source/sequences/blog_seq.sql;
@source/build/create_synonyms.sql;
@source/build/functions.sql;
@source/build/create_views.sql;
@source/packages/blog_log_pkg.pks;
@source/packages/blog_log_pkg.pkb;
@source/packages/blog_xml_pkg.pks;
@source/packages/blog_xml_pkg.pkb;
@source/packages/blog_util_pkg.pks;
@source/packages/blog_util_pkg.pkb;
@source/packages/blog_plugin_pkg.pks;
set define off;
@source/packages/blog_plugin_pkg.pkb;
set define on;
@source/packages/blog_job_pkg.pks;
@source/packages/blog_job_pkg.pkb;
@source/packages/blog_install_pkg.pks;
@source/packages/blog_install_pkg.pkb;
@source/packages/blog_admin_app_pkg.pks;
@source/packages/blog_admin_app_pkg.pkb;
@source/packages/blog_mailchimp_pkg.pks;
@source/packages/blog_mailchimp_pkg.pkb;
@source/build/triggers.sql;
--@source/seed/parameter_data.sql;
@source/seed/admin.sql;
@source/apex/f209021.sql;
@source/apex/f427.sql;
/
