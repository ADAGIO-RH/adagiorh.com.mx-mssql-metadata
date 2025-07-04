USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblContactosEmpleadosTiposNotificaciones](
	[IDContactoEmpleadoTipoNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDTipoNotificacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTemplateNotificacion] [int] NOT NULL,
	[IDContactoEmpleado] [int] NULL,
 CONSTRAINT [PK_RHtblContactosEmpleadosTiposNotificaciones_IDContactoEmpleadoTipoNotificacion] PRIMARY KEY CLUSTERED 
(
	[IDContactoEmpleadoTipoNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblTemplateNotificaciones_RHtblContactosEmpleadosTiposNotificaciones_IDTemplateNotificacion] FOREIGN KEY([IDTemplateNotificacion])
REFERENCES [App].[tblTemplateNotificaciones] ([IDTemplateNotificacion])
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones] CHECK CONSTRAINT [FK_AppTblTemplateNotificaciones_RHtblContactosEmpleadosTiposNotificaciones_IDTemplateNotificacion]
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_AppTblTiposNotificaciones_RHtblContactosEmpleadosTiposNotificaciones_IDTipoNotificacion] FOREIGN KEY([IDTipoNotificacion])
REFERENCES [App].[tblTiposNotificaciones] ([IDTipoNotificacion])
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones] CHECK CONSTRAINT [FK_AppTblTiposNotificaciones_RHtblContactosEmpleadosTiposNotificaciones_IDTipoNotificacion]
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_RHTblContactoEmpleado_RHtblContactosEmpleadosTiposNotificaciones_IDContactoEmpleado] FOREIGN KEY([IDContactoEmpleado])
REFERENCES [RH].[tblContactoEmpleado] ([IDContactoEmpleado])
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones] CHECK CONSTRAINT [FK_RHTblContactoEmpleado_RHtblContactosEmpleadosTiposNotificaciones_IDContactoEmpleado]
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpleados_RHtblContactosEmpleadosTiposNotificaciones_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblContactosEmpleadosTiposNotificaciones] CHECK CONSTRAINT [FK_RHTblEmpleados_RHtblContactosEmpleadosTiposNotificaciones_IDEmpleado]
GO
