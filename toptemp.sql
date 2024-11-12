set lines 400
col sql_id format a20
col temp_max format 999,999,999.99 heading "Temp Usage |Max (MB)"
col first_used format a20
col last_used format a20

set verify off
set feedback off
VAR INSTID NUMBER;
VAR SNAP1 NUMBER;
VAR SNAP2 NUMBER;

BEGIN
 :SNAP1  := &1;
 :SNAP2  := &2;
 :INSTID := &3;
END;
/
set feedback on


column NODE new_value _mcNODE 
column CNAME new_value _mcCNAME 
SET termout off
SELECT LISTAGG(instance_name, ',') WITHIN GROUP (ORDER BY inst_id) AS NODE,
       max((case when version >= '12.1' then sys_context('USERENV','CON_NAME') else 'N/A' end)) as CNAME
  FROM GV$INSTANCE 
 WHERE (:INSTID = 0 or inst_id = :INSTID);
SET termout ON

PROMP
PROMP Metric....: TOP 20 SQL Id by Temp Usage (ASH/AWR)
PROMP Snapshots.: &1 to &2
PROMP Instance..: &_mcNODE
PROMP Con. Name.: &_mcCNAME
PROMP

select rownum as top, x.*
from (select sql_id, 
             max(temp_max) temp_max,
             to_char(min(sample_time),'dd/mm/yyyy hh24:mi:ss') as first_used, 
             to_char(max(sample_time),'dd/mm/yyyy hh24:mi:ss') as last_used
        from (select h.sample_time, 
                     h.sql_id, 
                     round(sum(nvl(h.temp_space_allocated, 0))/1024/1024,2) temp_max
                from dba_hist_active_sess_history h
               where 1=1 
	             and (:INSTID = 0 or h.instance_number = :INSTID)
	             and h.snap_id >  :SNAP1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	             and h.snap_id <= :SNAP2
                 and nvl(h.temp_space_allocated, 0) > 0
            group by sample_time, sql_id
		    )
       group by sql_id
       order by temp_max desc
      ) x
where rownum <= 20;