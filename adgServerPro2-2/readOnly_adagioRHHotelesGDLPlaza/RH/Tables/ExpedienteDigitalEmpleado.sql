USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[ExpedienteDigitalEmpleado](
	[IDExpedienteDigitalEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDExpedienteDigital] [int] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ContentType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Data] [varbinary](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[IDExpedienteDigitalEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
