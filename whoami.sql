set heading off
select 'DB_NAME (from v$database) : '||name,
       'SESSION_USER              : '||sys_context('USERENV','SESSION_USER'),
       'AUTHENTICATED_IDENTITY    : '||sys_context('USERENV','AUTHENTICATED_IDENTITY'),
       'AUTHENTICATION_METHOD     : '||sys_context('USERENV','AUTHENTICATION_METHOD'),
       'LDAP_SERVER_TYPE          : '||sys_context('USERENV','LDAP_SERVER_TYPE'),
       'ENTERPRISE_IDENTITY       : '||sys_context('USERENV','ENTERPRISE_IDENTITY')
from v$database;
set heading on;

