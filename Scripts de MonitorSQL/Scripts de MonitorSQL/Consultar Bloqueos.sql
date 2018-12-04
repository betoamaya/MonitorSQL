SELECT (wait_duration_ms) / 6000,
       *
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL;

/**********************************************************/

SELECT dowt.blocking_session_id,
       dowt.wait_duration_ms,
       CONVERT(VARCHAR, DATEADD(MILLISECOND, dowt.wait_duration_ms, '00:00:00'), 114) AS Duración,
       dowt.session_id
FROM sys.dm_os_waiting_tasks AS dowt
WHERE dowt.blocking_session_id IS NOT NULL;


/********************************************************/

SELECT der.blocking_session_id,
       der.session_id,
       der.wait_type,
       der.wait_time,
       CONVERT(VARCHAR, DATEADD(MILLISECOND, der.wait_time, '00:00:00'), 114) AS Duración
FROM sys.dm_exec_requests AS der
WHERE der.blocking_session_id <> 0
ORDER BY der.wait_time DESC;

DBCC INPUTBUFFER(55);
/*
BEGIN TRAN   INSERT CAT.IT_Config  (      idServidor,      isMonitor,      iDiasLog,      iIntervaloMonitor,      iOrden,      dUltimoCambio  )  VALUES  (   100,        -- idServidor - int      NULL,     -- isMonitor - bit      0,        -- iDiasLog - int      0,        -- iIntervaloMonitor - int      0,        -- iOrden - int      GETDATE() -- dUltimoCambio - datetime  )
*/

DECLARE @sqltext VARBINARY(128);
SELECT @sqltext = sql_handle
FROM sys.sysprocesses
WHERE spid = 55;
SELECT *
FROM sys.dm_exec_sql_text(@sqltext);

SELECT s.spid,
       s.dbid,
       DB_NAME(s.dbid) AS dbName,
       s.status,
       (
           SELECT dest.text FROM sys.dm_exec_sql_text(s.sql_handle) AS dest
       ) AS text,
       s.hostname,
       s.program_name,
       s.cmd,
       s.loginame,
       *
FROM sys.sysprocesses AS s
WHERE spid = 55;



/*+++++++++++++++++++++*/
SELECT session_id,
       blocking_session_id,
       wait_time,
       wait_type,
       last_wait_type,
       wait_resource,
       der.transaction_isolation_level,
       lock_timeout
FROM sys.dm_exec_requests AS der
WHERE der.blocking_session_id <> 0;


SELECT session_id,
       status,
       blocking_session_id,
       wait_type,
       wait_time,
       wait_resource,
       transaction_id
FROM sys.dm_exec_requests
WHERE status = N'suspended';


SELECT *
FROM sys.dm_exec_requests AS der
WHERE der.session_id = 55;

SELECT session_id,
       wait_duration_ms,
       wait_type,
       blocking_session_id
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id <> 0;

/***********************************************************/

EXEC sp_who;


SELECT scheduler_id,
       current_tasks_count,
       runnable_tasks_count
FROM sys.dm_os_schedulers
WHERE scheduler_id < 255;



SELECT t1.resource_type AS 'lock type',
       DB_NAME(resource_database_id) AS 'database',
       t1.resource_associated_entity_id AS 'blk object',
       t1.request_mode AS 'lock req', --- lock requested
       t1.request_session_id AS 'waiter sid',
       t2.wait_duration_ms AS 'wait time',
       (
           SELECT [text]
           FROM sys.dm_exec_requests AS r
               CROSS APPLY sys.dm_exec_sql_text(r.sql_handle)
           WHERE r.session_id = t1.request_session_id
       ) AS 'waiter_batch',
       (
           SELECT SUBSTRING(   qt.text,
                               r.statement_start_offset / 2,
                               (CASE
                                    WHEN r.statement_end_offset = -1 THEN
                                        LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                                    ELSE
                                        r.statement_end_offset
                                END - r.statement_start_offset
                               ) / 2
                           )
           FROM sys.dm_exec_requests AS r
               CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS qt
           WHERE r.session_id = t1.request_session_id
       ) AS 'waiter_stmt',
       t2.blocking_session_id AS 'blocker sid',
       (
           SELECT [text]
           FROM sys.sysprocesses AS p
               CROSS APPLY sys.dm_exec_sql_text(p.sql_handle)
           WHERE p.spid = t2.blocking_session_id
       ) AS 'blocker_stmt'
FROM sys.dm_tran_locks AS t1
    INNER JOIN sys.dm_os_waiting_tasks AS t2
        ON t1.lock_owner_address = t2.resource_address;


SELECT t1.resource_type,
       t1.resource_database_id,
       t1.resource_associated_entity_id,
       t1.request_mode,
       t1.request_session_id,
       t2.blocking_session_id
FROM sys.dm_tran_locks AS t1
    INNER JOIN sys.dm_os_waiting_tasks AS t2
        ON t1.lock_owner_address = t2.resource_address;




/*************************************************************/


SELECT s.spid,
       s.status,
       s.blocked,
       s.open_tran,
       s.waitresource,
       s.waittype,
       s.waittime,
       s.cmd,
       s.lastwaittype
FROM sys.sysprocesses AS s
WHERE s.blocked = 55;



/************************************************************/

SELECT s.spid,
       s.status,
       s.loginame,
       s.hostname,
       dec.client_net_address,
       DB_NAME(s.dbid) AS dbName,
       (
           SELECT dest.text FROM sys.dm_exec_sql_text(s.sql_handle) AS dest
       ) AS text,
       s.open_tran,
       s.cmd,
       s.lastwaittype
FROM sys.sysprocesses AS s
    LEFT JOIN sys.dm_exec_connections AS dec
        ON s.spid = dec.session_id
WHERE s.spid IN (
                    SELECT DISTINCT
                        s2.blocked
                    FROM sys.sysprocesses AS s2
                    WHERE s2.blocked <> 0
                )
      AND s.blocked = 0;

/*******************************************************************/


