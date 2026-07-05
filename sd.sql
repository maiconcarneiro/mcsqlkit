/*
 Script: sd.sql 
 Example @sd <SESSION ID> <INST_ID>
 Maicon Carneiro - Jul 5, 2026
*/

SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF

DECLARE
    v_sid     NUMBER := &1;
    v_inst_id NUMBER := &2;
    v_count   NUMBER := 0;
    
    -- Variables to hold dynamically queried database columns (for version safety)
    v_plsql_debug  VARCHAR2(10) := 'N/A';
    v_drain_status VARCHAR2(10) := 'N/A';
BEGIN
    -- Check for newer version-specific columns so the script doesn't fail on older DBs
    BEGIN
        EXECUTE IMMEDIATE 
          'SELECT plsql_debugger_connected, drain_status ' ||
          'FROM gv$session WHERE sid = :1 AND inst_id = :2 AND ROWNUM = 1'
          INTO v_plsql_debug, v_drain_status
          USING v_sid, v_inst_id;
    EXCEPTION
        WHEN OTHERS THEN 
            -- Safe fallback if the columns do not exist in the database version
            v_plsql_debug  := 'N/A';
            v_drain_status := 'N/A';
    END;

    DBMS_OUTPUT.PUT_LINE('===========================================================');
    DBMS_OUTPUT.PUT_LINE('Session Details and Status Flags for SID: ' || v_sid || ' on INST_ID: ' || v_inst_id);
    DBMS_OUTPUT.PUT_LINE('===========================================================');

    FOR rec IN (
        SELECT 
            inst_id AS n, 
            sid, 
            serial#, 
            machine, 
            username,
            program,
            module,
            action,
            client_info,
            -- --- CORE TRANSACTION / SESSION STATUS ---
            status,                        -- ACTIVE, INACTIVE, KILLED, CACHED, SNIPED
            schemaname,
            osuser,
            -- --- WAIT & BLOCKING STATUS ---
            state,                         -- WAITING, WAITED KNOWN TIME, etc.
            blocking_session_status,       -- VALID, NO HOLDER, NOT IN WAIT, UNKNOWN
            blocking_session,
            blocking_instance,
            final_blocking_session_status, -- VALID, NO HOLDER, NOT IN WAIT, UNKNOWN
            final_blocking_session,
            final_blocking_instance,
            -- --- HIGH AVAILABILITY & FAILOVER STATUS ---
            failover_type,                 -- NONE, SESSION, SELECT, TRANSACTION
            failover_method,               -- NONE, BASIC, PRECONNECT
            failed_over,                   -- YES, NO
            -- --- PARALLEL EXECUTION STATUS ---
            pdml_status,                   -- ENABLED, DISABLED, FORCED
            pddl_status,                   -- ENABLED, DISABLED, FORCED
            pq_status,                     -- ENABLED, DISABLED, FORCED
            -- --- GENERAL DETAILS ---
            TO_CHAR(logon_time, 'yyyy-mm-dd hh24:mi:ss') AS logon_time,
            TO_CHAR(sql_exec_start, 'yyyy-mm-dd hh24:mi:ss') AS sql_exec_start, 
            TO_CHAR(prev_exec_start, 'yyyy-mm-dd hh24:mi:ss') AS prev_exec_start,
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
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('INST_ID (N)                   : ' || rec.n);
        DBMS_OUTPUT.PUT_LINE('SID                           : ' || rec.sid);
        DBMS_OUTPUT.PUT_LINE('SERIAL#                       : ' || rec.serial#);
        DBMS_OUTPUT.PUT_LINE('USERNAME                      : ' || rec.username);
        DBMS_OUTPUT.PUT_LINE('OSUSER                        : ' || rec.osuser);
        DBMS_OUTPUT.PUT_LINE('SCHEMANAME                    : ' || rec.schemaname);
        DBMS_OUTPUT.PUT_LINE('MACHINE                       : ' || rec.machine);
        DBMS_OUTPUT.PUT_LINE('PROGRAM                       : ' || rec.program);
        DBMS_OUTPUT.PUT_LINE('MODULE                        : ' || rec.module);
        DBMS_OUTPUT.PUT_LINE('ACTION                        : ' || rec.action);
        DBMS_OUTPUT.PUT_LINE('CLIENT_INFO                   : ' || rec.client_info);
        DBMS_OUTPUT.PUT_LINE('LOGON_TIME                    : ' || rec.logon_time);
        DBMS_OUTPUT.PUT_LINE('SQL_EXEC_START                : ' || rec.sql_exec_start);
        DBMS_OUTPUT.PUT_LINE('PREV_EXEC_START               : ' || rec.prev_exec_start);
        DBMS_OUTPUT.PUT_LINE('EVENT                         : ' || rec.event);
        
        -- Core & Wait Statuses
        DBMS_OUTPUT.PUT_LINE('SESSION STATUS (STATUS)       : ' || rec.status);
        DBMS_OUTPUT.PUT_LINE('WAIT STATE (STATE)            : ' || rec.state);
        
        -- Blocking Statuses
        DBMS_OUTPUT.PUT_LINE('BLOCKING_SESSION_STATUS       : ' || rec.blocking_session_status);
        DBMS_OUTPUT.PUT_LINE('BLOCKING_SESSION              : ' || rec.blocking_session);
        DBMS_OUTPUT.PUT_LINE('BLOCKING_INSTANCE             : ' || rec.blocking_instance);
        DBMS_OUTPUT.PUT_LINE('FINAL_BLOCKING_SESSION_STATUS : ' || rec.final_blocking_session_status);
        DBMS_OUTPUT.PUT_LINE('FINAL_BLOCKING_SESSION        : ' || rec.final_blocking_session);
        DBMS_OUTPUT.PUT_LINE('FINAL_BLOCKING_INSTANCE       : ' || rec.final_blocking_instance);
        
        -- Failover Statuses
        DBMS_OUTPUT.PUT_LINE('FAILOVER_TYPE                 : ' || rec.failover_type);
        DBMS_OUTPUT.PUT_LINE('FAILOVER_METHOD               : ' || rec.failover_method);
        DBMS_OUTPUT.PUT_LINE('FAILED_OVER                   : ' || rec.failed_over);
        
        -- Parallel Statuses
        DBMS_OUTPUT.PUT_LINE('PDML_STATUS                   : ' || rec.pdml_status);
        DBMS_OUTPUT.PUT_LINE('PDDL_STATUS                   : ' || rec.pddl_status);
        DBMS_OUTPUT.PUT_LINE('PQ_STATUS                     : ' || rec.pq_status);
        
        -- Modern Debugger & Connection Draining Statuses
        DBMS_OUTPUT.PUT_LINE('PLSQL_DEBUGGER_CONNECTED      : ' || v_plsql_debug);
        DBMS_OUTPUT.PUT_LINE('DRAIN_STATUS                  : ' || v_drain_status);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------');
    END LOOP;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No session found matching the criteria.');
    END IF;
    
END;
/
