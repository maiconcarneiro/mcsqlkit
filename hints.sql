set lines 400
col hint for a200
select hint from (
select p.name, p.signature, p.category,
       row_number() over (partition by sd.signature, sd.category order by sd.signature) row_num,
       extractValue(value(t), '/hint') hint
from sys.sqlobj$data sd, sys.dba_sql_profiles p,
     table(xmlsequence(extract(xmltype(sd.comp_data),
                               '/outline_data/hint'))) t
where sd.obj_type = 1
and p.signature = sd.signature
and p.name like nvl('&1',name)
)
order by row_num
/