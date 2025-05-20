set feedback off
set heading off
set verify off
set sqlformat
set lines 1000
set long 999999
col sql_text format a500
select format_sql(sql_text)  as sql_text from dba_hist_sqltext where sql_id='&1' and rownum=1;
set heading on
set feedback on



select format_sql('SELECT * FROM tbl',
  'FormatConfig.builder()
    .indent("    ") // Defaults to two spaces
    .uppercase(true) // Defaults to false (not safe to use when SQL dialect has case-sensitive identifiers)
    .linesBetweenQueries(2) // Defaults to 1
    .maxColumnLength(100) // Defaults to 50
    .params(Arrays.asList("a", "b", "c")) // Map or List. See Placeholders replacement.
    .build()'
) from dual;