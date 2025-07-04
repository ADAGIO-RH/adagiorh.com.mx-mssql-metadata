USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblLogCajaAhorro](
	[IDLogCajaAhorro] [int] IDENTITY(1,1) NOT NULL,
	[Accion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCajaAhorro] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Monto] [decimal](18, 2) NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_NominaTblLogCajaAhorro_IDCajaAhorro] PRIMARY KEY CLUSTERED 
(
	[IDLogCajaAhorro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblLogCajaAhorro] ADD  CONSTRAINT [D_NominaTblLogCajaAhorro_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Nomina].[tblLogCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblLogCajaAhorroRHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblLogCajaAhorro] CHECK CONSTRAINT [Fk_NominaTblLogCajaAhorroRHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [Nomina].[tblLogCajaAhorro]  WITH CHECK ADD  CONSTRAINT [Fk_TblLogCajaAhorroTblUsuarios_IDusuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblLogCajaAhorro] CHECK CONSTRAINT [Fk_TblLogCajaAhorroTblUsuarios_IDusuario]
GO
