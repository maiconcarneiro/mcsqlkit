/*
 Script...: switchgb.sql
 Syntax...: @switchgb <Qt_Days>
 Purpose..: Show the history of generated archived logs per hour in GB for the last N days.

 Author...: Maicon Carneiro (dibiei.blog)
 Created..: 2026-04-01
 Updated..: 2026-04-01
*/

PROMP
PROMP Metric....: Generated archived logs per hour in GB for the last N days
PROMP Qt. Days..: &1
PROMP


set pages 999 
set linesize 400
col day format a5
col h0  format 999.9
col h1  format 999.9
col h2  format 999.9
col h3  format 999.9
col h4  format 999.9
col h5  format 999.9
col h6  format 999.9
col h7  format 999.9
col h8  format 999.9
col h9  format 999.9
col h10 format 999.9
col h11 format 999.9
col h12 format 999.9
col h13 format 999.9
col h14 format 999.9
col h15 format 999.9
col h16 format 999.9
col h17 format 999.9
col h18 format 999.9
col h19 format 999.9
col h20 format 999.9
col h21 format 999.9
col h22 format 999.9
col h23 format 999.9

SELECT
 TRUNC (COMPLETION_TIME) "Date", TO_CHAR (COMPLETION_TIME, 'Dy') "Day",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '00', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h0",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '01', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h1",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '02', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h2",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '03', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h3",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '04', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h4",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '05', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h5",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '06', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h6",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '07', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h7",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '08', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h8",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '09', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h9",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '10', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h10",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '11', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h11",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '12', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h12",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '13', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h13",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '14', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h14",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '15', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h15",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '16', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h16",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '17', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h17",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '18', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h18",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '19', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h19",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '20', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h20",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '21', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h21",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '22', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h22",
 SUM (DECODE (TO_CHAR (COMPLETION_TIME, 'hh24'), '23', (BLOCKS*BLOCK_SIZE), 0)) /1024/1024/1024 as "h23"
FROM GV$ARCHIVED_LOG
WHERE thread# = inst_id
AND COMPLETION_TIME > trunc(sysdate) - &1
GROUP BY TRUNC (COMPLETION_TIME), TO_CHAR (COMPLETION_TIME, 'Dy')
ORDER BY 1,2;