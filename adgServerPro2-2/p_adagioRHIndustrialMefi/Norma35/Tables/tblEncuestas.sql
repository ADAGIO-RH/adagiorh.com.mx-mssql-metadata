USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblEncuestas](
	[IDEncuesta] [int] IDENTITY(1,1) NOT NULL,
	[IDCatEncuesta] [int] NOT NULL,
	[NombreEncuesta] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaIni] [date] NULL,
	[FechaFin] [date] NULL,
	[IDEmpresa] [int] NULL,
	[IDSucursal] [int] NULL,
	[CantidadEmpleados] [int] NULL,
	[EsAnonimo] [bit] NULL,
	[IDCatEstatus] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[IDUsuario] [int] NULL,
	[IDCliente] [int] NULL,
 CONSTRAINT [PK_Norma35tblEncuestas_IDEncuesta] PRIMARY KEY CLUSTERED 
(
	[IDEncuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblEncuestas] ADD  CONSTRAINT [d_Norma35tblEncuestas_CantidadEmpleados]  DEFAULT ((0)) FOR [CantidadEmpleados]
GO
ALTER TABLE [Norma35].[tblEncuestas] ADD  CONSTRAINT [d_Norma35tblEncuestas_EsAnomimo]  DEFAULT ((0)) FOR [EsAnonimo]
GO
ALTER TABLE [Norma35].[tblEncuestas] ADD  CONSTRAINT [d_Norma35tblEncuestas_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblCatEncuestas_Norma35TblEncuesta_IDCatEncueta] FOREIGN KEY([IDCatEncuesta])
REFERENCES [Norma35].[tblCatEncuestas] ([IDCatEncuesta])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_Norma35TblCatEncuestas_Norma35TblEncuesta_IDCatEncueta]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35tblCatEstatus_Norma35tblEncuestas_IDCatEstatus] FOREIGN KEY([IDCatEstatus])
REFERENCES [Norma35].[tblCatEstatus] ([IDCatEstatus])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_Norma35tblCatEstatus_Norma35tblEncuestas_IDCatEstatus]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblEncuestas_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_Norma35TblEncuestas_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_Norma35TblEncuesta_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_RHTblCatClientes_Norma35TblEncuesta_IDCliente]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatSucursales_Norma35TblEncuesta_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_RHTblCatSucursales_Norma35TblEncuesta_IDSucursal]
GO
ALTER TABLE [Norma35].[tblEncuestas]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpresa_Norma35tblEncuesta_IDEmpresa] FOREIGN KEY([IDEmpresa])
REFERENCES [RH].[tblEmpresa] ([IdEmpresa])
GO
ALTER TABLE [Norma35].[tblEncuestas] CHECK CONSTRAINT [FK_RHTblEmpresa_Norma35tblEncuesta_IDEmpresa]
GO
