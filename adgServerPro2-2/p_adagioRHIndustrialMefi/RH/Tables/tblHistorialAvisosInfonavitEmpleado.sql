USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblHistorialAvisosInfonavitEmpleado](
	[IDHistorialAvisosInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[NumeroCredito] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FolioAviso] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaOtorgamiento] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechCreaAviso] [datetime] NULL,
	[FacDescuento] [decimal](18, 4) NULL,
	[MonDescuento] [decimal](18, 4) NULL,
	[SelloDigital] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CadenaOriginal] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[IDTipoAvisoInfonavit] [int] NULL,
	[IDTipoCredito] [int] NULL,
	[FechaUltimoAviso] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHtblHistorialAvisosInfonavitEmpleado_IDHistorialAvisosInfonavitEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDHistorialAvisosInfonavitEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHtblHistorialAvisoInfonavitEmpleado_IDTipoDescuento] FOREIGN KEY([IDTipoDescuento])
REFERENCES [RH].[tblCatInfonavitTipoDescuento] ([IDTipoDescuento])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatInfonavitTipoDescuento_RHtblHistorialAvisoInfonavitEmpleado_IDTipoDescuento]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_tblHistorialAvisoInfonavitEmpleado_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_tblHistorialAvisoInfonavitEmpleado_IDRegPatronal]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblcatTiposAvisosInfonavit_rhtblHistorialAvisoInfonavitEmpleado_IDTipoAvisoInfonavit] FOREIGN KEY([IDTipoAvisoInfonavit])
REFERENCES [RH].[tblcatTiposAvisosInfonavit] ([IDTipoAvisoInfonavit])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_RHtblcatTiposAvisosInfonavit_rhtblHistorialAvisoInfonavitEmpleado_IDTipoAvisoInfonavit]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_tblHistorialAvisoInfonavitEmpleado_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_tblHistorialAvisoInfonavitEmpleado_RHtblEmpleados_IDEmpleado]
GO
