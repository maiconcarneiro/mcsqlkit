
SET SQLBLANKLINES ON
set termout off;
COLUMN INSTANCE_VERSION NEW_VALUE _ORA_VERSION
COLUMN VERSION_SUFFIX NEW_VALUE _VERSION_SUFFIX
SELECT VERSION,
       CASE WHEN VERSION < '12.1' THEN '11g' ELSE '' END as VERSION_SUFFIX
  FROM V$INSTANCE;
set termout on;


-- format sqlcl
@f1