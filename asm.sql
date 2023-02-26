SET SQLFORMAT
COL NAME HEADING "Disksgroup"
COL TYPE HEADING "Redundancy"
COL TOTAL_GB HEADING "Total GB" FORMAT 999,999,999,999  
COL FREE_GB  HEADING "Free GB"  FORMAT 999,999,999,999 
COL PERCFREE HEADING "Free %"   FORMAT 999.99 

SELECT NAME, TYPE, TOTAL_GB, FREE_GB, ROUND(FREE_GB/TOTAL_GB*100,2) AS PERCFREE
FROM (
	SELECT NAME, 
	       TYPE,
		   ( TOTAL_MB / DECODE(TYPE,'HIGH',3,'NORMAL',2,1) ) / 1024 AS TOTAL_GB, 
		   USABLE_FILE_MB/1024 AS FREE_GB
	FROM V$ASM_DISKGROUP
);