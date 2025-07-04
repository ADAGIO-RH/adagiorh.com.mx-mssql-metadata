USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatPosiciones](
	[IDPosicion] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[IDPlaza] [int] NOT NULL,
	[Codigo] [App].[SMName] NOT NULL,
	[IDEmpleado] [int] NULL,
	[IDUsuarioUltimoReclutador] [int] NULL,
	[ParentId] [int] NULL,
	[Temporal] [bit] NULL,
	[DisponibleDesde] [date] NULL,
	[DisponibleHasta] [date] NULL,
	[UUID] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDReclutador] [int] NULL,
 CONSTRAINT [Pk_RHTblCatPosiciones_IDPosicion] PRIMARY KEY CLUSTERED 
(
	[IDPosicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatPosiciones] ADD  CONSTRAINT [U_RHTblCatPosiciones_ParentId]  DEFAULT ((0)) FOR [ParentId]
GO
ALTER TABLE [RH].[tblCatPosiciones] ADD  CONSTRAINT [D_RHTblCatPosiciones_Temporal]  DEFAULT ((0)) FOR [Temporal]
GO
ALTER TABLE [RH].[tblCatPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatPosiciones_RHTblCatClientes_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [RH].[tblCatPosiciones] CHECK CONSTRAINT [Fk_RHTblCatPosiciones_RHTblCatClientes_IDCliente]
GO
ALTER TABLE [RH].[tblCatPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatPosiciones_RHTblCatPlazas_IDPlaza] FOREIGN KEY([IDPlaza])
REFERENCES [RH].[tblCatPlazas] ([IDPlaza])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblCatPosiciones] CHECK CONSTRAINT [Fk_RHTblCatPosiciones_RHTblCatPlazas_IDPlaza]
GO
ALTER TABLE [RH].[tblCatPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatPosiciones_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblCatPosiciones] CHECK CONSTRAINT [Fk_RHTblCatPosiciones_RHTblEmpleados_IDEmpleado]
GO
ALTER TABLE [RH].[tblCatPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblCatPosiciones_SeguridadTblUsuarios_IDUsuarioUltimoReclutador] FOREIGN KEY([IDUsuarioUltimoReclutador])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblCatPosiciones] CHECK CONSTRAINT [Fk_RHTblCatPosiciones_SeguridadTblUsuarios_IDUsuarioUltimoReclutador]
GO
