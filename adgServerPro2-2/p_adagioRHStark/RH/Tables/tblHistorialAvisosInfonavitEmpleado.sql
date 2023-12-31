USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblHistorialAvisosInfonavitEmpleado](
	[IDHistorialAvisosInfonavitEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDInfonavitEmpleado] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[NumeroCredito] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Fecha] [date] NOT NULL,
	[IDTipoDescuento] [int] NOT NULL,
	[ValorDescuento] [decimal](18, 4) NULL,
	[AplicaDisminucion] [bit] NULL,
	[FolioAviso] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaEntraVigor] [date] NULL,
	[IDTipoAvisoInfonavit] [int] NULL,
	[FechaFinVigor] [date] NULL,
 CONSTRAINT [PK_RHtblHistorialAvisosInfonavitEmpleado_IDHistorialAvisosInfonavitEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDHistorialAvisosInfonavitEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] ADD  DEFAULT ((0)) FOR [AplicaDisminucion]
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
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblHistorialAvisoInfonavitEmpleado_IDInfonavitEmpleado] FOREIGN KEY([IDInfonavitEmpleado])
REFERENCES [RH].[tblInfonavitEmpleado] ([IDInfonavitEmpleado])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_RHTblInfonavitEmpleado_RHtblHistorialAvisoInfonavitEmpleado_IDInfonavitEmpleado]
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_tblHistorialAvisoInfonavitEmpleado_RHtblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblHistorialAvisosInfonavitEmpleado] CHECK CONSTRAINT [FK_tblHistorialAvisoInfonavitEmpleado_RHtblEmpleados_IDEmpleado]
GO
