create or replace package blog_mailchimp_pkg as 

--create a new merge_field
procedure create_merge_field(p_list_id  in varchar2,
                             p_name     in varchar2,
                             p_merge_id out integer,
                             p_tag      out varchar2);

--update the default value of an existing merge_field
procedure update_merge_field (p_list_id     in varchar2, ---the id of the list
                              p_merge_id    in number,   ---the id of the merge field
                              p_merge_field in varchar2, ---the name of the merge field
                              p_merge_value in varchar2, --the value you want to pass into the email
                              p_success     out boolean);

--create a new email campaign
procedure create_campaign ( p_list_id      in varchar2,
                            p_subject_line in varchar2,
                            p_title        in varchar2,
                            p_template_id  in number,
                            p_reply_to     in varchar2,
                            p_from_name    in varchar2,
                            p_send_url     out varchar2);

--send email campaign
procedure send_campaign (p_send_url in varchar2,
                         p_success  out boolean);

end blog_mailchimp_pkg;
/