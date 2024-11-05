set serveroutput on
set ver off

set termout off
  column 1 new_value 1
  select null as "1" from dual where 1 = 2;
set termout on

declare
    l_some_text varchar2(1000);
begin
   select nvl('&1', 'no_text_given') into l_some_text from dual;
   dbms_output.put_line('SQL uses: ' || l_some_text );
end ;
/