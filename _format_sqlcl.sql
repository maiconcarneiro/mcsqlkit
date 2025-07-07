-- custom prompt
COLUMN my_prompt NEW_VALUE my_prompt_var
SELECT '@|yellow '|| LOWER(USER) || '|@@@|red ' || SYS_CONTEXT('USERENV','CON_NAME') || '|@@|white > |@' AS my_prompt FROM dual;
SET SQLPROMPT &my_prompt_var

-- enable SQLPLUS like formatation
set sqlformat