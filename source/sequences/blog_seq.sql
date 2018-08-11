DECLARE
  v_dummy NUMBER;
BEGIN
  -- try to find sequence in data dictionary
  SELECT 1
  INTO v_dummy
  FROM user_sequences
  WHERE sequence_name = 'BLOG_SEQ';

  -- if sequence found, do nothing
EXCEPTION
  WHEN no_data_found THEN
    -- sequence not found, create it
    EXECUTE IMMEDIATE 'CREATE SEQUENCE   "BLOG_SEQ"  MINVALUE 1 MAXVALUE 9999 INCREMENT BY 1 START WITH 51 CACHE 50 NOORDER  CYCLE';
END;
/