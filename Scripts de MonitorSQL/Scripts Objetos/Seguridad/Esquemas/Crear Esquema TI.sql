USE [Operacion_Respaldo]
GO

IF EXISTS(SELECT s.name FROM sys.schemas AS s WHERE s.name = 'TI')
BEGIN
	DROP SCHEMA [TI]    
END
GO

CREATE SCHEMA [TI]
GO
