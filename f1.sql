set feedback off;
set termout off;
COLUMN SCRIPT_FORMAT NEW_VALUE _SCRIPT_FORMAT
SELECT CASE WHEN  sys_context('USERENV','MODULE') = 'SQLcl'
            THEN 'format_sqlcl.sql'
            ELSE 'format_sqlplus.sql'
        END SCRIPT_FORMAT
FROM DUAL;

@&_SCRIPT_FORMAT

set feedback on;
set termout on;
