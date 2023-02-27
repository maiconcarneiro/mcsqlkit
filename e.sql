-- Author: Maicon Carneiro (dibiei.com)
set pagesize 100
col event format a50
SELECT EVENT, COUNT(*) 
FROM GV$SESSION 
WHERE TYPE='USER' 
AND STATUS = 'ACTIVE' 
GROUP BY EVENT 
ORDER BY 2 DESC;
