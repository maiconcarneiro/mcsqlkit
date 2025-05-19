/* Script exavault.sql
   Shows the spaced provisioned and used in the Exascale Vault

   Maicon Carneiro (dibiei.blog)
   13/04/2025
*/

set lines 200
col vault_name       heading 'Vault|Name'                     format a20
col hc_iops_prov     heading 'High Capacity|IOPS Provisioned' format 999,999,999.99
col hc_space_prov    heading 'High Capacity|Provisioned (GB)' format 999,999,999.99
col hc_space_used    heading 'High Capacity|Space Used (GB)'  format 999,999,999.99
col hc_percent_used  heading 'High Capacity|Space Used (%)'   format 999.99
col flash_cache_prov heading 'Flash Cache|Provisioned (GB)'   format 999,999,999.99
col xrmem_cache_prov heading 'XRMEN Cache|Provisioned (GB)'   format 999,999,999.99
select vault_name                                    as vault_name
      ,hc_iops_prov                                  as hc_iops_prov
      ,(hc_space_prov/3)/1024/1024/1024              as hc_space_prov
      ,(hc_space_used/3)/1024/1024/1024              as hc_space_used
      ,(hc_space_used/greatest(hc_space_prov,1)*100) as hc_percent_used
      ,flash_cache_prov/1024/1024/1024               as flash_cache_prov
      ,xrmem_cache_prov/1024/1024/1024               as xrmem_cache_prov
from sys.v_$exa_vault;