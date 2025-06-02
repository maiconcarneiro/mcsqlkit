set pagesize 60
set linesize 300
set trimspool on
 
column  sql_text format a40
column  plan_name format a30
column  signature format 999999999999999999999
column  hint format a50 wrap word
 
select
        prf.plan_name,
        prf.sql_text,
        prf.signature,
        extractvalue(value(hnt),'.') hint
from
        (
        select
                so.name         plan_name,
                so.signature,
                so.category,
                so.obj_type,
                so.plan_id,
                st.sql_text,
                sod.comp_data
                from
                        sys.sqlobj$         so,
                        sys.sqlobj$data     sod,
                        sys.sql$text        st
                where
                        sod.signature = so.signature
                and     st.signature = so.signature
                and     st.signature = sod.signature
                and     sod.category = so.category
                and     sod.obj_type = so.obj_type
                and     sod.plan_id = so.plan_id
                and     so.obj_type = 3
                and     so.name = '&1'
                order by
                        signature, obj_type, plan_id
        )       prf,
        table (
                select
                        xmlsequence(
                                extract(xmltype(prf.comp_data),'/outline_data/hint')
                        )
                from
                        dual
        )       hnt
;