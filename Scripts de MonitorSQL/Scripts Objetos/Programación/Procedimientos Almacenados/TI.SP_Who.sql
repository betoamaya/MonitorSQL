SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Responsable:		Roberto Amaya
-- Ultimo Cambio:	04/12/2018
-- Descripcion:		Procedimiento para obtener los bloqueos en el Servidor
-- =============================================
CREATE PROCEDURE [TI].[SP_Who]
AS
BEGIN

    SET NOCOUNT ON;
    /*VARIABLES*/
    DECLARE @tBloqueos AS TABLE
    (
        SPID SMALLINT NULL,
        Status NCHAR(30) NULL,
        Loginame NCHAR(128) NULL,
        Hostname NCHAR(128) NULL,
        NetAddress NVARCHAR(48) NULL,
        DBname NVARCHAR(128) NULL,
        Text NVARCHAR(MAX) NULL,
        OpenTran SMALLINT NULL,
        Cmd NCHAR(16) NULL
    );
    /*OBTENER REGISTROS DE BLOQUEOS*/
    INSERT INTO @tBloqueos
    (
        SPID,
        Status,
        Loginame,
        Hostname,
        NetAddress,
        DBname,
        Text,
        OpenTran,
        Cmd
    )
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

    /*GUARDAR REGISTROS DE BLOQUEOS*/
    IF @@ROWCOUNT > 0
    BEGIN
        INSERT INTO TI.BloqueosLog
        (
            SPID,
            Status,
            Loginame,
            Hostname,
            NetAddress,
            DBname,
            Text,
            OpenTran,
            Cmd,
            FechaRegistro
        )
        SELECT tb.SPID,
               tb.Status,
               tb.Loginame,
               tb.Hostname,
               tb.NetAddress,
               tb.DBname,
               tb.Text,
               tb.OpenTran,
               tb.Cmd,
               GETDATE()
        FROM @tBloqueos AS tb;
    END;
    /*RESULTADO DE LA CONSULTA*/

    SELECT tb.SPID,
           tb.DBname,
           tb.Text,
		   tb.Loginame,
		   tb.Hostname
    FROM @tBloqueos AS tb;

END;
GO
