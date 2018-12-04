USE [Operacion_Respaldo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [TI].[BloqueosLog](
	[IdLog] [BIGINT] IDENTITY(1,1) NOT NULL,
	[SPID] [SMALLINT] NULL,
	[Status] [NCHAR](30) NULL,
	[Loginame] [NCHAR](128) NULL,
	[Hostname] [NCHAR](128) NULL,
	[NetAddress] [NVARCHAR](48) NULL,
	[DBname] [NVARCHAR](128) NULL,
	[Text] [NVARCHAR](MAX) NULL,
	[OpenTran] [SMALLINT] NULL,
	[Cmd] [NCHAR](16) NULL,
	[FechaRegistro] [DATETIME] NULL,
 CONSTRAINT [PK_BloqueosLog] PRIMARY KEY CLUSTERED 
(
	[IdLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [TI].[BloqueosLog] ADD  CONSTRAINT [DF_BloqueosLog_FechaRegistro]  DEFAULT (GETDATE()) FOR [FechaRegistro]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para llevar registro de los bloqueos en el servidor' , @level0type=N'SCHEMA',@level0name=N'TI', @level1type=N'TABLE',@level1name=N'BloqueosLog'
GO


