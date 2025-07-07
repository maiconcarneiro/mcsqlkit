set feedback off;
set termout off;

/*
COLUMN SCRIPT_FORMAT NEW_VALUE _SCRIPT_FORMAT
SELECT CASE WHEN  sys_context('USERENV','MODULE') = 'SQLcl'
            THEN '_format_sqlcl.sql'
            ELSE '_format_sqlplus.sql'
        END SCRIPT_FORMAT
FROM DUAL;

@&_SCRIPT_FORMAT
*/


COLUMN my_prompt NEW_VALUE my_prompt_var
SELECT (CASE WHEN sys_context('USERENV','MODULE') = 'SQLcl' 
             THEN '@|yellow '|| LOWER(USER) || '|@@@|red ' || SYS_CONTEXT('USERENV','CON_NAME') || '|@@|white > |@' 
             ELSE LOWER(USER) || '@' || SYS_CONTEXT('USERENV','DB_NAME') || '>  ' 
        END) AS my_prompt FROM dual;

SET SQLPROMPT &my_prompt_var

set feedback on;
set termout on;
