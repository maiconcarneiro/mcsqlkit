-- -----------------------------------------------------------------------------------
-- File Name    : session_px
-- Author       : Pedro Vido
-- Description  : Displays the te QC cordinator e Slaves of parallel executions.
-- Comments     : .
-- Requirements : Access to the GV$ views.
-- Call Syntax  : @session_px
-- Last Modified: 07/07/2023
-- -----------------------------------------------------------------------------------

SET SQLFORMAT
col username for a20
col QC_Slave format a10
col QC_SID format a10
col Slave_Set format a20
col module format a20
col sid for a8
set lines 299
COLUMN event FORMAT A34 WORD_WRAP TRUNC
COLUMN sql_fulltext FORMAT A34 WORD_WRAP TRUNC
select s.inst_id,
decode(px.qcinst_id,NULL,s.username,
' - '||lower(substr(s.program,length(s.program)-4,4) ) ) "Username", 
s.sql_id,
s.event,
s.module,
decode(px.qcinst_id,NULL, 'QC', '(Slave)') QC_Slave ,
to_char( px.server_set) Slave_Set,
to_char(s.sid) "SID",
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) QC_SID,
px.req_degree "Requested DOP",
px.degree "Actual DOP", 
p.spid
from gv$px_session px, 
     gv$session s, 
     gv$process p
where px.sid=s.sid (+) 
and px.serial#=s.serial# 
and px.inst_id = s.inst_id 
and p.inst_id = s.inst_id 
and p.addr=s.paddr
--and s.username = 'SYSTEM'
order by 3 , 5 desc;