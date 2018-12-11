CREATE TYPE subscriber_typ AS OBJECT (
    email_address    VARCHAR2(100),
    first_name       VARCHAR2(50),
    last_name        VARCHAR2(50),
    status           varchar2(50)
  )
/
CREATE TYPE subscriber_typ_set AS TABLE OF subscriber_typ
/
CREATE TYPE merge_field_typ AS OBJECT (
    merge_id       INTEGER,
    tag            VARCHAR2(50),
    name           VARCHAR2(50),
    default_value  VARCHAR2(2000)
  )
/
CREATE TYPE merge_field_typ_set AS TABLE OF merge_field_typ
/
CREATE TYPE campaign_history_typ AS OBJECT (
    campaign_id        VARCHAR2(50),
    emails_sent        INTEGER,
    send_time          DATE,
    recipient_list_id  VARCHAR2(2000),
    template_id        INTEGER,
    subject_line       VARCHAR2(100),
    from_name          VARCHAR2(200),
    opens              INTEGER,
    unique_opens       INTEGER,
    open_rate          INTEGER,
    clicks             INTEGER,
    cancel_send        VARCHAR2(1000)
  )
/
CREATE TYPE campaign_history_typ_set AS TABLE OF campaign_history_typ
/