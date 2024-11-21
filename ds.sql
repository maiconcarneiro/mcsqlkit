/*
 Script para consulta as metricas de um SQL ID na GV$SQL e retorna valores médios por execução
 Exemplo: @ds <SQL_ID>

 Maicon Carneiro | dibiei.blog
*/

def _LAST_SQL_ID=&1;
@ds_filter&_VERSION_SUFFIX sql_id sql_id='&1' 1
