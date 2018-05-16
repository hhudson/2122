set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_default_workspace_id=>5510843774547541
);
end;
/
prompt  WORKSPACE 5510843774547541
--
-- Workspace, User Group, User, and Team Development Export:
--   Date and Time:   15:49 Sunday May 6, 2018
--   Exported By:     HAYDEN
--   Export Type:     Workspace Export
--   Version:         5.1.3.00.05
--   Instance ID:     108840466845548
--
-- Import:
--   Using Instance Administration / Manage Workspaces
--   or
--   Using SQL*Plus as the Oracle user APEX_050100
 
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>5510843774547541);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace HAYDEN...
begin
wwv_flow_fnd_user_api.create_company (
  p_id => 5511057652547639
 ,p_provisioning_company_id => 5510843774547541
 ,p_short_name => 'HAYDEN'
 ,p_display_name => 'HAYDEN'
 ,p_first_schema_provisioned => 'HAYDEN'
 ,p_company_schemas => 'HAYDEN'
 ,p_ws_schema => 'HAYDEN'
 ,p_account_status => 'ASSIGNED'
 ,p_allow_plsql_editing => 'Y'
 ,p_allow_app_building_yn => 'Y'
 ,p_allow_packaged_app_ins_yn => 'Y'
 ,p_allow_sql_workshop_yn => 'Y'
 ,p_allow_websheet_dev_yn => 'Y'
 ,p_allow_team_development_yn => 'Y'
 ,p_allow_to_be_purged_yn => 'Y'
 ,p_allow_restful_services_yn => 'Y'
 ,p_source_identifier => 'HAYDEN'
 ,p_path_prefix => 'HAYDEN'
 ,p_files_version => 2
);
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
begin
wwv_flow_api.create_user_groups (
  p_id => 1670338847171665,
  p_GROUP_NAME => 'OAuth2 Client Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to register OAuth2 Client Applications');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1670236590171665,
  p_GROUP_NAME => 'RESTful Services',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use RESTful Services with this workspace');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1670163835171662,
  p_GROUP_NAME => 'SQL Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use SQL Developer with this workspace');
end;
/
prompt  Creating group grants...
----------------
-- U S E R S
-- User repository for use with APEX cookie-based authentication.
--
prompt  Creating Users...
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '5510718096547541',
  p_user_name                    => 'ADMIN',
  p_first_name                   => 'Hayden',
  p_last_name                    => 'Hudson',
  p_description                  => '',
  p_email_address                => 'hayden@concept2completion.com',
  p_web_password                 => '185FAEBFBFAFA9D10B4995F05DD1F56237A459ED219C057FDEE9424DADABE243CA22086B9CCC864044D747B0E3C227635E03DAC128DD2CF1495EA67123C53D38',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '1670163835171662:1670236590171665:1670338847171665:',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'HAYDEN',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201607121444','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 1,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'Y',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '12343960955403223',
  p_user_name                    => 'BRAD.KNIGHT',
  p_first_name                   => '',
  p_last_name                    => '',
  p_description                  => '',
  p_email_address                => 'brad.knight@oracle.com',
  p_web_password                 => 'D0984A1AFD487FC1D536B37FBC6ACC2600A433F8F510DCEF8B2B781E67AE233073854DB0EA8AFEE261314C3AD18B7FE2F41B101B08F1039A4443289560588073',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'CREATE:EDIT:HELP:MONITOR:SQL:MONITOR:DATA_LOADER',
  p_default_schema               => 'HAYDEN',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201702150000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '27138488369212325',
  p_user_name                    => 'HAYDEN',
  p_first_name                   => 'Hayden',
  p_last_name                    => 'Hudson',
  p_description                  => '',
  p_email_address                => 'hayden.hudson@concept2completion.com',
  p_web_password                 => '32BF9FCAE342C8D75119E83C95ECC9C8141F844FB0E8CB399F40AD5939C26ECA14A3913128D12EA12DD4C7B6445D704CBDA635DD07EBD215508C2672D9BD8C8F',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '1670163835171662:1670236590171665:1670338847171665:',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'HAYDEN',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201609190000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '12344941270414425',
  p_user_name                    => 'JOHN.BELL',
  p_first_name                   => '',
  p_last_name                    => '',
  p_description                  => '',
  p_email_address                => 'john.bell@oracle.com',
  p_web_password                 => '7D816822AE0B1E262EBBD5D8149524DC84E456446CA81720722BD1A02DBCF80811D74D5FFDF569F49FA6161A927AE0805E44E8FC6A12E89A8769623C15AEDE3F',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => '',
  p_default_schema               => 'HAYDEN',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201702150000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '12344421345410396',
  p_user_name                    => 'SUSIE.PARKER',
  p_first_name                   => '',
  p_last_name                    => '',
  p_description                  => '',
  p_email_address                => 'susie.parker@oracle.com',
  p_web_password                 => '7869899788B11BD0AD3F7CEAD756F2D5FA45F291C4836510B462173D5ACE066CCA7AA517376B676C59DE64BC3F364A3CAE49523958ACCD1F719C616A5B10B48B',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'HAYDEN',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201702150000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
