/*
 Script: sd2.sql 
 Example @sd <SESSION ID> <INST_ID>
 Maicon Carneiro - Jul 5, 2026
*/

SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF

DECLARE
    v_sid     NUMBER := &1;
    v_inst_id NUMBER := &2;
    v_count   NUMBER := 0;
    
    -- Variables to hold dynamically queried database columns (for safety & cross-version compatibility)
    v_auth_type    VARCHAR2(128) := 'N/A';
    v_plsql_debug  VARCHAR2(10)  := 'N/A';
    v_drain_status VARCHAR2(10)  := 'N/A';
    v_con_name     VARCHAR2(128) := 'N/A';
BEGIN
    -- 1. Resolve Authentication Type safely from GV$SESSION_CONNECT_INFO
    BEGIN
        EXECUTE IMMEDIATE 
          'SELECT DISTINCT authentication_type ' ||
          'FROM gv$session_connect_info ' ||
          'WHERE sid = :1 AND inst_id = :2 AND ROWNUM = 1'
          INTO v_auth_type
          USING v_sid, v_inst_id;
    EXCEPTION
        WHEN OTHERS THEN 
            v_auth_type := 'UNKNOWN / NOT FOUND';
    END;

    -- 2. Resolve version-specific columns (PDB Container Name, Debugger, and Drain Status)
    BEGIN
        EXECUTE IMMEDIATE 
          'SELECT plsql_debugger_connected, drain_status, con_name ' ||
          'FROM gv$session s, v$containers c ' ||
          'WHERE s.con_id = c.con_id(+) AND s.sid = :1 AND s.inst_id = :2 AND ROWNUM = 1'
          INTO v_plsql_debug, v_drain_status, v_con_name;
    EXCEPTION
        WHEN OTHERS THEN 
            -- Fallback for non-multitenant or older versions
            BEGIN
                EXECUTE IMMEDIATE 
                  'SELECT plsql_debugger_connected, drain_status ' ||
                  'FROM gv$session WHERE sid = :1 AND inst_id = :2 AND ROWNUM = 1'
                  INTO v_plsql_debug, v_drain_status;
            EXCEPTION
                WHEN OTHERS THEN
                    v_plsql_debug  := 'N/A';
                    v_drain_status := 'N/A';
            END;
            v_con_name := 'N/A';
    END;

    DBMS_OUTPUT.PUT_LINE('=====================================================================');
    DBMS_OUTPUT.PUT_LINE('Detailed Session Connection Fingerprint for SID: ' || v_sid || ' on INST_ID: ' || v_inst_id);
    DBMS_OUTPUT.PUT_LINE('=====================================================================');

    FOR rec IN (
        SELECT 
            inst_id AS n, 
            sid, 
            serial#, 
            machine, 
            username,
            osuser,
            schemaname,
            -- APPLICATION/CLIENT TRACKING
            program,                       
            module,                        
            action,                        
            client_info,                   
            client_identifier,             
            -- SERVICE & NETWORK IDENTIFICATION
            service_name,                  
            port,                          
            process,                       
            type,                          
            logon_time,
            -- WAIT & BLOCKING STATUS
            status,
            state,
            event
        FROM 
            gv$session
        WHERE 
            sid = v_sid 
            AND inst_id = v_inst_id
        ORDER BY 
            logon_time
    ) LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE('RECORD                        : ' || v_count);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('INST_ID (N)                   : ' || rec.n);
        DBMS_OUTPUT.PUT_LINE('SID                           : ' || rec.sid);
        DBMS_OUTPUT.PUT_LINE('SERIAL#                       : ' || rec.serial#);
        DBMS_OUTPUT.PUT_LINE('SESSION TYPE                  : ' || rec.type);
        DBMS_OUTPUT.PUT_LINE('LOGON_TIME                    : ' || TO_CHAR(rec.logon_time, 'yyyy-mm-dd hh24:mi:ss'));
        
        DBMS_OUTPUT.PUT_LINE('--- OS and USER AUTHENTICATION');
        DBMS_OUTPUT.PUT_LINE('DB USERNAME                   : ' || rec.username);
        DBMS_OUTPUT.PUT_LINE('DB SCHEMA NAME                : ' || rec.schemaname);
        DBMS_OUTPUT.PUT_LINE('CLIENT OS USER                : ' || rec.osuser);
        DBMS_OUTPUT.PUT_LINE('AUTH TYPE (VIA CONNECT_INFO)  : ' || v_auth_type);
        DBMS_OUTPUT.PUT_LINE('PDB CONTAINER NAME            : ' || v_con_name);
        
        DBMS_OUTPUT.PUT_LINE('--- CLIENT / APPLICATION TRACING');
        DBMS_OUTPUT.PUT_LINE('PROGRAM                       : ' || rec.program);
        DBMS_OUTPUT.PUT_LINE('MODULE                        : ' || rec.module);
        DBMS_OUTPUT.PUT_LINE('ACTION                        : ' || rec.action);
        DBMS_OUTPUT.PUT_LINE('CLIENT_INFO                   : ' || rec.client_info);
        DBMS_OUTPUT.PUT_LINE('CLIENT_IDENTIFIER             : ' || rec.client_identifier);
        
        DBMS_OUTPUT.PUT_LINE('--- NETWORK and PROCESS IDENTIFICATION');
        DBMS_OUTPUT.PUT_LINE('CLIENT MACHINE                : ' || rec.machine);
        DBMS_OUTPUT.PUT_LINE('CLIENT PORT                   : ' || rec.port);
        DBMS_OUTPUT.PUT_LINE('CLIENT OS PROCESS (PID)       : ' || rec.process);
        DBMS_OUTPUT.PUT_LINE('DB SERVICE NAME               : ' || rec.service_name);
        
        DBMS_OUTPUT.PUT_LINE('--- CURRENT ACTIVITY and STATUS');
        DBMS_OUTPUT.PUT_LINE('STATUS                        : ' || rec.status);
        DBMS_OUTPUT.PUT_LINE('WAIT STATE (STATE)            : ' || rec.state);
        DBMS_OUTPUT.PUT_LINE('LAST EVENT                    : ' || rec.event);
        DBMS_OUTPUT.PUT_LINE('PLSQL_DEBUGGER_CONNECTED      : ' || v_plsql_debug);
        DBMS_OUTPUT.PUT_LINE('DRAIN_STATUS                  : ' || v_drain_status);
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
    END LOOP;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No session found matching the criteria.');
    END IF;
    
END;
/
