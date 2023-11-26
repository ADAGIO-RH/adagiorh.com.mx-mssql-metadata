USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[ExpedienteDigitalEmpleado_20230503](
	[IDExpedienteDigitalEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDExpedienteDigital] [int] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ContentType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Data] [varbinary](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
