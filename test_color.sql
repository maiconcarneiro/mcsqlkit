def _COLOR_NUMBER=&1
/*
select 
CHR(27)||'[48;5;'
       || ( 16 + MOD(&&_COLOR_NUMBER,6) + MOD(TRUNC(&&_COLOR_NUMBER/6),6)*6 + MOD(TRUNC(&&_COLOR_NUMBER/36),6)*6*6 )
       ||'m'
       || 'test'
       || CHR(27)||'[0m' as test
from dual;
*/

/*
select 
CHR(27)||'[48;5;'
       || ( 16 + MOD(180,6) + MOD(TRUNC(180/6),6)*6 + MOD(TRUNC(180/36),6)*6*6 )
       ||'m'
       || 'test'
       || CHR(27)||'[0m' as test
from dual;
*/

select 
CHR(27)||'[48;5;196m'
       || 'test'
       || CHR(27)||'[0m' as test
from dual;

select CHR(27)|| '[48;5;196)m' || '2.7M' || CHR(27)||'[0m' as color FROM DUAL;