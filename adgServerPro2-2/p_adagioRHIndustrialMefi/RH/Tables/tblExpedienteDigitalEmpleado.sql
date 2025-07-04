USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblExpedienteDigitalEmpleado](
	[IDExpedienteDigitalEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDExpedienteDigital] [int] NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ContentType] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathFile] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
	[FechaVencimiento] [datetime] NULL,
	[FechaCreacion] [datetime] NULL,
 CONSTRAINT [PK_RHExpedienteDigitalEmpleado_IDExpedienteDigitalEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDExpedienteDigitalEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblExpedienteDigitalEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatExpedientesDigitales_RHtblExpedienteDigitalEmpleado_IDExpedienteDigital] FOREIGN KEY([IDExpedienteDigital])
REFERENCES [RH].[tblCatExpedientesDigitales] ([IDExpedienteDigital])
GO
ALTER TABLE [RH].[tblExpedienteDigitalEmpleado] CHECK CONSTRAINT [FK_RHtblCatExpedientesDigitales_RHtblExpedienteDigitalEmpleado_IDExpedienteDigital]
GO
ALTER TABLE [RH].[tblExpedienteDigitalEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHTblExpedienteDigitalEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblExpedienteDigitalEmpleado] CHECK CONSTRAINT [FK_RHTblEmpleados_RHTblExpedienteDigitalEmpleado_IDEmpleado]
GO
