COLUMN my_prompt NEW_VALUE my_prompt_var
SELECT LOWER(USER) || '@' || SYS_CONTEXT('USERENV','DB_NAME') || '> ' AS my_prompt FROM dual;
SET SQLPROMPT &my_prompt_var