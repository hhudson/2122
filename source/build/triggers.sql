CREATE OR REPLACE TRIGGER blog_param_trg before
INSERT OR
UPDATE ON blog_param FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'),USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
     :NEW.changed_by := COALESCE(v('APP_USER'),USER);
    END IF;
  END IF;
  IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'),USER);
  END IF;
END;
/
ALTER TRIGGER blog_param_trg ENABLE;
/
CREATE OR REPLACE TRIGGER blog_faq_trg before
 INSERT OR
 UPDATE ON blog_faq FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.faq_id IS NULL THEN
      :NEW.faq_id := blog_sgid;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
  END IF;
  IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;
END;
/
ALTER TRIGGER blog_faq_trg ENABLE;
/

CREATE OR REPLACE TRIGGER blog_contact_message_trg before
 INSERT OR
 UPDATE ON blog_contact_message FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.contact_id IS NULL THEN
      :NEW.contact_id := blog_sgid;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
  END IF;
  IF updating THEN
   :NEW.changed_on := SYSDATE;
   :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;
END;
/
ALTER TRIGGER blog_contact_message_trg ENABLE;

/

CREATE OR REPLACE TRIGGER blog_comment_user_trg before
 INSERT OR
 UPDATE ON blog_comment_user FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.user_id IS NULL THEN
      :NEW.user_id := blog_sgid;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'),USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'),USER);
    END IF;
  END IF;
  IF updating THEN
   :NEW.changed_on := SYSDATE;
   :NEW.changed_by := COALESCE(v('APP_USER'),USER);
  END IF;
  IF :NEW.blocked = 'Y' THEN
    IF :NEW.blocked_on IS NULL THEN
      :NEW.blocked_on := SYSDATE;
    END IF;
  ELSE
    :NEW.blocked_on := NULL;
  END IF;
END;
/
ALTER TRIGGER blog_comment_user_trg ENABLE;
/

CREATE OR REPLACE TRIGGER blog_comment_trg before
 INSERT OR
 UPDATE ON blog_comment FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.comment_id IS NULL THEN
      :NEW.comment_id := blog_sgid;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
  END IF;
  IF updating THEN
   :NEW.changed_on := SYSDATE;
   :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;

  IF :NEW.moderated = 'Y' THEN
    IF :NEW.moderated_on IS NULL THEN
      :NEW.moderated_on := SYSDATE;
    END IF;
  ELSE
    :NEW.moderated_on := NULL;
  END IF;
  IF :NEW.notify_email_sent = 'Y' THEN
    IF :NEW.notify_email_sent_on IS NULL THEN
      :NEW.notify_email_sent_on := SYSDATE;
    END IF;
  ELSE
    :NEW.notify_email_sent_on := NULL;
  END IF;
END;
/
ALTER TRIGGER blog_comment_trg ENABLE;

/

CREATE OR REPLACE TRIGGER blog_comment_notify_trg before
 INSERT OR
 UPDATE ON blog_comment_notify FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
   END IF;
   IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;
END;
/
ALTER TRIGGER blog_comment_notify_trg ENABLE;
/

CREATE OR REPLACE TRIGGER blog_comment_block_trg before
 INSERT OR
 UPDATE ON blog_comment_block FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.block_id IS NULL THEN
      :NEW.block_id := blog_sgid;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
  END IF;
  IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;
END;
/
ALTER TRIGGER blog_comment_block_trg ENABLE;

/

CREATE OR REPLACE TRIGGER blog_author_trg before
 INSERT OR
 UPDATE OR
 DELETE ON blog_author FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.author_id IS NULL THEN
    -- Author is inserted to users table as blocked.
    -- Posted by for comments can be then queried from one table.
    -- Also it prevent commenting using author email address.
      INSERT INTO blog_comment_user (email, nick_name, blocked, blocked_on, user_type)
      VALUES (:NEW.email, :NEW.author_name, 'Y', SYSDATE, 'A')
      RETURNING user_id INTO :NEW.author_id;
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'),USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'),USER);
    END IF;
  END IF;
  IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'),USER);
    UPDATE blog_comment_user
    SET nick_name = :NEW.author_name,
            email = :NEW.email
    WHERE user_id = :NEW.author_id;
  END IF;
  IF deleting THEN
    DELETE FROM blog_comment_user
    WHERE user_id = :OLD.author_id;
  END IF;
END;
/
ALTER TRIGGER blog_author_trg ENABLE;
/
CREATE OR REPLACE TRIGGER blog_posts_trg before
 INSERT OR
 UPDATE ON blog_posts FOR EACH row
BEGIN
  IF inserting THEN
    IF :NEW.email_list_id IS NULL THEN
       :NEW.email_list_id := blog_mailchimp_pkg.create_list (p_list_name           => :NEW.page_id||'_list', 
                                                             p_permission_reminder => 'You are receiving this email because you commented on this blog post.');
    END IF;
    IF :NEW.created_by IS NULL THEN
      :NEW.created_by := COALESCE(v('APP_USER'), USER);
    END IF;
    IF :NEW.changed_by IS NULL THEN
      :NEW.changed_by := COALESCE(v('APP_USER'), USER);
    END IF;
  END IF;
  IF updating THEN
    :NEW.changed_on := SYSDATE;
    :NEW.changed_by := COALESCE(v('APP_USER'), USER);
  END IF;
END;
/
ALTER TRIGGER blog_posts_trg ENABLE;
/