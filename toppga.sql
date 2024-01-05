set lines 400
col sql_id format a20
col pga_max format 999,999,999.99 heading "Max PGA Usage (GB)"
select *
from (select sql_id, max(pga_sum_gb) pga_max
        from (select h.sample_time, h.sql_id, round(sum(nvl(h.pga_allocated, 0))/1024/1024/1024) pga_sum_gb
                from dba_hist_active_sess_history h
               where 1=1 
	             and (&3 = 0 or h.instance_number = &3)
	             and h.snap_id >  &1 -- O TOP 10 no AWR em HTML desconsidera o snapshot 
	             and h.snap_id <= &2 
            group by sample_time, sql_id
		    )
       group by sql_id
       order by pga_max desc)
where rownum <= 20;