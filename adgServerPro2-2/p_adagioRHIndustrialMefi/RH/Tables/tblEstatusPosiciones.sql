USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEstatusPosiciones](
	[IDEstatusPosicion] [int] IDENTITY(1,1) NOT NULL,
	[IDPosicion] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
	[DisponibleDesde] [date] NULL,
	[DisponibleHasta] [date] NULL,
	[FechaReg] [datetime] NOT NULL,
	[IDUsuario] [int] NULL,
	[IDEmpleado] [int] NULL,
	[IDReclutador] [int] NULL,
	[ContratoDesdeReclutamiento] [bit] NULL,
 CONSTRAINT [Pk_RHTblEstatusPosiciones_IDEstatusPosicion] PRIMARY KEY CLUSTERED 
(
	[IDEstatusPosicion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEstatusPosiciones] ADD  CONSTRAINT [D_RHTblEstatusPosiciones_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [RH].[tblEstatusPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEstatusPosiciones_RHTblCatPosiciones_IDPosicion] FOREIGN KEY([IDPosicion])
REFERENCES [RH].[tblCatPosiciones] ([IDPosicion])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblEstatusPosiciones] CHECK CONSTRAINT [Fk_RHTblEstatusPosiciones_RHTblCatPosiciones_IDPosicion]
GO
ALTER TABLE [RH].[tblEstatusPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEstatusPosiciones_RHTblEmpleados_IDReclutador] FOREIGN KEY([IDReclutador])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblEstatusPosiciones] CHECK CONSTRAINT [Fk_RHTblEstatusPosiciones_RHTblEmpleados_IDReclutador]
GO
ALTER TABLE [RH].[tblEstatusPosiciones]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEstatusPosiciones_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblEstatusPosiciones] CHECK CONSTRAINT [Fk_RHTblEstatusPosiciones_SeguridadTblUsuarios_IDUsuario]
GO
