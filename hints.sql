set lines 155
col hint for a150
select hint from (
select p.name, p.signature, p.category,
       row_number()
         over (partition by sd.signature, sd.category order by sd.signature) row_num,
       extractValue(value(t), '/hint') hint
from sqlobj$data sd, dba_sql_profiles p,
     table(xmlsequence(extract(xmltype(sd.comp_data),
                               '/outline_data/hint'))) t
where sd.	 = 1
and p.signature = sd.signature
and p.name like nvl('&1',name)
)
order by row_num
/