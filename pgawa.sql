DEF _COLUMN_ALIAS='VALUE'
DEF _COL_NUM_FORMAT='999,999'

set termout off;
COLUMN PGA_PASS_HELPER_COLUMN NEW_VALUE _PGA_PASS_HELPER_COLUMN
COLUMN DIVISOR NEW_VALUE _DIVISOR
select (case when &3 = 0 then 'OPTIMAL_EXECUTIONS'
            when &3 = 1 then 'ONEPASS_EXECUTIONS'
            when &3 = 2 then 'MULTIPASSES_EXECUTIONS'
            else 'TOTAL_EXECUTIONS'
       end) as PGA_PASS_HELPER_COLUMN,

      (case when &3 = 0 then 1000
            when &3 = 1 then 1
            when &3 = 2 then 1
            else 1000
       end) as DIVISOR

from dual;
set termout on;

@pgawa_helper &1 &2