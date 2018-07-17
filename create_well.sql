declare
  l_read_id             varchar2(100);
  l_well                well.well%type;
  l_primer_set_type_id  well.primer_set_type_id%type;
  l_plate_id            number;
  l_id                  number;
  l_plate_number integer := :P5_PLATE_NUMBER;
  l_count integer;
begin
for i in 1..:P5_BULK_PLATE_COUNT
loop
    l_plate_number := l_plate_number + 1;
    Insert into SERES.PLATE (PLATE_START_DATE,PLATE_NUMBER,PLATE_NAME,CONTAINS_C_DIFF,REGION_TYPE_CODE,PROGRAM,NOTES,COMPLETED) values (:P5_PLATE_START_DATE,l_plate_number,'SEQ'||to_char(to_date(:P5_PLATE_START_DATE),'yyyymmdd')||'_'||l_plate_number,:P5_CONTAINS_C_DIFF,:P5_REGION_TYPE_CODE,:P5_PROGRAM,:P5_NOTES,:P5_COMPLETED);
    returning id into l_plate_id;

    :F_NEW_PLATE_NUMBER := null;

  -- Set value for Read ID. This will only be used when Sample Type is NTC.
  l_read_id := 'SQN'||to_char(to_date(:P5_PLATE_START_DATE,'mm/dd/yyyy'),'yymmdd')||'_'||:P5_PLATE_NUMBER;

  begin
    select id
      into l_primer_set_type_id
      from primer_set_type
     where region_type_code = :P5_REGION_TYPE_CODE
       and default_value    = 'Y'
       and rownum = 1;
  exception
    when others then
      l_primer_set_type_id := null;
  end;

  for a in 1 .. 94 loop
    if a between 1 and 12 then
      l_well := 'A'||LPAD(a,2,'0');
    elsif a between 13 and 24 then
      l_well := 'B'||LPAD(a - 12,2,'0');
    elsif a between 25 and 36 then
      l_well := 'C'||LPAD(a - 24,2,'0');
    elsif a between 37 and 48 then
      l_well := 'D'||LPAD(a - 36,2,'0');
    elsif a between 49 and 60 then
      l_well := 'E'||LPAD(a - 48,2,'0');
    elsif a between 61 and 72 then
      l_well := 'F'||LPAD(a - 60,2,'0');
    elsif a between 73 and 84 then
      l_well := 'G'||LPAD(a - 72,2,'0');
    elsif a between 85 and 94 then
      l_well := 'H'||LPAD(a - 84,2,'0');
    else
      null;
    end if;

    begin
      insert into well
        (plate_id, well, primer_set_type_id, sample_type_code, read_id)
      values
        (l_plate_id, l_well, l_primer_set_type_id, case when l_well in ('H09','H10') then 'NTC' else null end, case when l_well in ('H09','H10') then l_read_id||l_well else null end)
      returning id into l_id;
    exception
      when others then
        l_id := null;
    end;

    -- Need to add the Forward and Reverse read values for the NTC records
    if l_well in ('H09','H10') then
       begin
         sf_utils.generate_reads(l_id);
       end;
    end if;


  end loop;
end loop;


end;
