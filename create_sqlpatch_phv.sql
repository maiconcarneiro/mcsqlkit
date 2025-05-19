/*
 Script: create_sql_patch_awr.sql
 This script can create a SQL Patch for an SQL ID using hints from specified Plan Hash Value that exists in AWR repository.
 The code was adjusted and tested to work properly in versions 11.2 to 19c.
 
 Author: Maicon Carneiro  (dibiei.blog)
*/


DECLARE
  --------- change these values ----------
  vSQL_ID varchar2(32) := '&1';
  vPHV    number       := &2;  -- Plan Hash Value
  ----------------------------------------

  -- changing the name pattern is optional
  vPatchName varchar2(30) := 'SQLPatch_' || vSQL_ID;

  
  vSQL_TEXT clob;
  vSQL_TEXT_legacy varchar2(4000);
  vHINT clob;
  vHINT_Legacy VARCHAR2(500);
  vVersion varchar2(20);
  vSQL varchar2(4000);
BEGIN

-- get sql_text of the sql_id from AWR
SELECT sql_text
  INTO vSQL_TEXT 
  FROM dba_hist_sqltext h
 WHERE sql_id = vSQL_ID
   AND rownum=1;

select version 
  into vVersion 
  from v$instance;

-- extract hints in the OTHER_XML column from the sql plan in AWR
 SELECT listagg(hint,' ') within group(order by rownum) 
   INTO vHINT
   FROM ( 
        SELECT b.hint
        FROM dba_hist_sql_plan m,
             xmltable ('/other_xml/outline_data/hint' passing xmltype (m.OTHER_XML) columns hint varchar2 (4000) PATH '/hint' ) b 
        WHERE TRIM( OTHER_XML ) IS NOT NULL 
          AND sql_id = vSQL_ID
          AND plan_hash_value = vPHV
        );
 
  if vVersion <= '12.1' then  
    -- for 11g and 12cR1
     vSQL_TEXT_legacy := substr(vSQL_TEXT, 1, 4000);
     vHINT_Legacy     := substr(vHINT, 1, 500);
     
     vSQL := '
          begin
            sys.dbms_sqldiag_internal.i_create_patch (
               sql_text  => :vSQL_TEXT_legacy, 
               hint_text => :vHINT_Legacy, 
               name      => :vPatchName
              );
           end;';
  
     EXECUTE IMMEDIATE vSQL USING IN vSQL_TEXT_legacy, vHINT_Legacy, vPatchName ;
     
  else
   -- for 12cR2 and later
    vSQL := '
        declare
          vResult varchar2(100);
        begin
         vResult := sys.dbms_sqldiag.create_sql_patch (
             sql_text  => :vSQL_TEXT, 
             hint_text => :vHINT, 
             name      => :vPatchName
             );
         end;
        ';
    
     EXECUTE IMMEDIATE vSQL USING IN vSQL_TEXT, vHINT, vPatchName ;
       
  end if;

END;
/
