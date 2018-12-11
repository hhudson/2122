begin
logger.purge_all;
end;
/
select id, substr(text,1,50) text, scope, length(extra)
from logger_logs
--where id > 639
order by id;
/
select page_name
        --into l_post_name
        from APEX_APPLICATION_PAGES
        where page_id = 31
        and workspace = 'BLOG_WORKSPACE'
        and APPLICATION_NAME='Blog';
/
DROP TYPE merge_field_typ;
create TYPE merge_field_typ as object (
    merge_id       integer,
    tag            VARCHAR2(50),
    name           VARCHAR2(50),
    default_value  VARCHAR2(2000)
  );
/
create type merge_field_typ_set as table of merge_field_typ;
/
DROP TABLE merge_field_typ_tbl;
create table merge_field_typ_tbl (
    merge_id       integer,
    tag            VARCHAR2(50),
    name           VARCHAR2(50),
    default_value  VARCHAR2(2000)
  );
/
select * from table(blog_mailchimp_pkg.get_list_of_merge_fields(p_list_id => 'ea51e856c9'))
/
select *
from table(blog_mailchimp_pkg.get_list_of_merge_fields(p_list_id => 'e6b1fde7b9'))
--where tag = 'POST_NAME'
order by merge_id
/
set serveroutput on
declare
l_merge_id integer;
l_tag      varchar2(50);
begin
blog_mailchimp_pkg.create_merge_field(  p_list_id     => 'e6b1fde7b9', --- the id of the list that would make use of this merge id
                                        p_merge_field => 'POST_NAME', --- the name you want to give the merge variable
                                        p_merge_id    => l_merge_id,
                                        p_tag         => l_tag);
dbms_output.put_line('l_merge_id :'||l_merge_id); --5
dbms_output.put_line('l_tag :'||l_tag); --MMERGE5
end;
/
declare
l_success0 boolean;
begin
blog_mailchimp_pkg.update_merge_field ( p_list_id     => 'e6b1fde7b9',
                                        --p_merge_id    => l_merge_id,
                                        p_tag         => 'POST_NAME',
                                        p_merge_value => 'Did this work?',
                                        p_success     => l_success0);
if l_success0 then
  dbms_output.put_line('success');
else
  dbms_output.put_line('failure');
end if;
end;
