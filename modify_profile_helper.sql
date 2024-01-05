BEGIN 
 DBMS_SQLTUNE.ALTER_SQL_PROFILE(name =>'&1', attribute_name=>'&2', value=>'&3');
END;
/