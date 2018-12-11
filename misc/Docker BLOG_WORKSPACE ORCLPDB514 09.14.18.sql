create TYPE campaign_history_typ as object (
    campaign_id        VARCHAR2(50),
    emails_sent        integer,
    send_time          DATE, --VARCHAR2(50),
    recipient_list_id  VARCHAR2(2000),
    template_id        integer,
    subject_line       varchar2(100),
    from_name          varchar2(200),
    opens              integer,
    unique_opens       integer,
    open_rate          integer,
    clicks             integer,
    cancel_send        varchar2(1000)
  );
/
DROP TABLE campaign_history_typ_TBL;
create type campaign_history_typ_set as table of campaign_history_typ;
/
create table campaign_history_typ_tbl (
    campaign_id        VARCHAR2(50),
    emails_sent        integer,
    send_time          DATE, --VARCHAR2(50),
    recipient_list_id  VARCHAR2(2000),
    template_id        integer,
    subject_line       varchar2(100),
    from_name          varchar2(200),
    opens              integer,
    unique_opens       integer,
    open_rate          integer,
    clicks             integer,
    cancel_send        varchar2(1000)
  );
/
select * --campaign_id, substr(send_time,1,instr(send_time,'+')-1), to_date(substr(send_time,1,instr(send_time,'+')-1), 'YYYY-MM-DD"T"HH24:MI:SS') as send_time --2018-09-13T12:41:09+00:00 YYYY-MM-DDThh:mm:ss+hh:mm
from table(blog_mailchimp_pkg.get_campaign_history)
--where campaign_id = '0549f6b349'