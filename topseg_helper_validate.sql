set feedback off;
set serveroutput on;
begin
  if '&_AWR_TOPSEG_COLUMN' not in (
     'logical_reads_delta',
     'buffer_busy_waits_delta',
     'db_block_changes_delta',
     'physical_reads_delta',
     'physical_writes_delta',
     'direct_physical_reads_delta',
     'direct_physical_writes_delta',
     'gc_cr_blocks_received_delta',
     'gc_current_blocks_received_delta',
     'gc_buffer_busy_delta',
     'itl_waits_delta',
     'row_lock_waits_delta',
     'global_cache_cr_blocks_served_delta',
     'global_cache_cu_blocks_served_delta'
     ) THEN
        DBMS_OUTPUT.PUT_LINE( CHR(27)||'[48;5;160m' || 'ERROR: &_AWR_TOPSEG_COLUMN is not supported with STATSPACK' || CHR(27)||'[0m');
     end if;
end;
/