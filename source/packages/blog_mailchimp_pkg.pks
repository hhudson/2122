create or replace package blog_mailchimp_pkg as 

procedure create_merge_field(p_list_id  in varchar2,
                             p_name     in varchar2,
                             p_merge_id out integer,
                             p_tag      out varchar2);

end blog_mailchimp_pkg;