def _COLOR_NUMBER=&1
select 
CHR(27)||'[48;5;'
       || ( 16 + MOD(&&_COLOR_NUMBER,6) + MOD(TRUNC(&&_COLOR_NUMBER/6),6)*6 + MOD(TRUNC(&&_COLOR_NUMBER/36),6)*6*6 )
       ||'m'
       ||LPAD(16 + MOD(&&_COLOR_NUMBER,6) + MOD(TRUNC(&&_COLOR_NUMBER/6),6)*6 + MOD(TRUNC(&&_COLOR_NUMBER/36),6)*6*6,4)
       || CHR(27)||'[0m' as 
from dual;


select 
CHR(27)||'[48;5;'
       || ( 16 + MOD(&&_COLOR_NUMBER,6) + MOD(TRUNC(&&_COLOR_NUMBER/6),6)*6 + MOD(TRUNC(&&_COLOR_NUMBER/36),6)*6*6 )
       ||'m'
       || 'test'
       || CHR(27)||'[0m' as 
from dual;