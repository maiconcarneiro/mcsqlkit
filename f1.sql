set feedback off;
set termout off;
COLUMN FORMAT_LINE NEW_VALUE _FORMAT_LINE
SELECT CASE WHEN  sys_context('USERENV','MODULE') = 'SQLcl'
            THEN '@|blue _USER|@@@|&_CON_NAME_COLOR &vCNAME|@@|white > |@'
            ELSE q'[_USER'@'&vCNAME> ]'
        END FORMAT_LINE
FROM DUAL;

set sqlprompt "&&_FORMAT_LINE";