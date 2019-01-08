SELECT * FROM master.sys.database_permissions AS dp   
    JOIN sys.system_objects AS so  
    ON dp.major_id = so.object_id  
    WHERE dp.class = 1 AND so.parent_object_id = 0 ;  
GO  


USE Operacion_Respaldo;  
--GRANT SELECT ON sys.sql_logins TO MonitorConsulta;  
GRANT VIEW SERVER STATE to MonitorConsulta;  
GO  