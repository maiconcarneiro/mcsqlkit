/*
 Script to query metrics for a SQL ID in GV$SQL and return average values per execution
 Example: @ds <SQL_ID>

 Maicon Carneiro | dibiei.blog
*/

def _LAST_SQL_ID=&1;
@ds_filter&_VERSION_SUFFIX sql_id sql_id='&1' 1
