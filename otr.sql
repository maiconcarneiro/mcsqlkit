SELECT
    s.sid,
    s.serial#,
    s.username,
    s.status,
    r.name AS rollback_segment,
    t.used_urec AS undo_records,
    t.used_ublk AS undo_blocks,
    t.start_time,
    s.osuser,
    s.program,
    s.sql_id
FROM v$transaction t
JOIN v$session s ON t.ses_addr = s.saddr
JOIN v$rollname r ON t.xidusn = r.usn
WHERE t.status = 'ROLLBACK';