USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblConfigAsignacionesPredeterminadas](
	[IDConfigAsignacionPredeterminada] [int] IDENTITY(1,1) NOT NULL,
	[IDDepartamento] [int] NULL,
	[IDSucursal] [int] NULL,
	[IDPuesto] [int] NULL,
	[IDClasificacionCorporativa] [int] NULL,
	[IDDivision] [int] NULL,
	[IDTipoNomina] [int] NULL,
	[IDsJefe] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDsLectores] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDsSupervisores] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Factor] [int] NULL,
	[IDUsuario] [int] NOT NULL,
	[IDCliente] [int] NULL,
	[IDAreas] [int] NULL,
	[IDCentroCostos] [int] NULL,
	[IDRazonSocial] [int] NULL,
	[IDRegiones] [int] NULL,
	[IDRegPatronal] [int] NULL,
	[IDTipoPrestaciones] [int] NULL,
 CONSTRAINT [Pk_RHTblConfigJefePredeterminado_IDConfigAsignacionPredeterminada] PRIMARY KEY CLUSTERED 
(
	[IDConfigAsignacionPredeterminada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblConfigAsignacionesPredeterminadas_UniqueRow] UNIQUE NONCLUSTERED 
(
	[IDDepartamento] ASC,
	[IDSucursal] ASC,
	[IDPuesto] ASC,
	[IDClasificacionCorporativa] ASC,
	[IDDivision] ASC,
	[IDTipoNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDclasificacionCorporativa] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDClasificacionCorporativa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDDepartamento] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDDivision] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDDivision] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDPuesto] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDSucursal] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblConfigAsignacionesPredeterminadas_IDTipoNomina] ON [RH].[tblConfigAsignacionesPredeterminadas]
(
	[IDTipoNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] ADD  CONSTRAINT [D_RHTblConfigAsignacionesPredeterminadas_Factor]  DEFAULT ((0)) FOR [Factor]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDClasificacionCorporativa] FOREIGN KEY([IDClasificacionCorporativa])
REFERENCES [RH].[tblCatClasificacionesCorporativas] ([IDClasificacionCorporativa])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDClasificacionCorporativa]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDDepartamento] FOREIGN KEY([IDDepartamento])
REFERENCES [RH].[tblCatDepartamentos] ([IDDepartamento])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDDepartamento]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDDivision] FOREIGN KEY([IDDivision])
REFERENCES [RH].[tblCatDivisiones] ([IDDivision])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDDivision]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDPuesto]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDSucursal] FOREIGN KEY([IDSucursal])
REFERENCES [RH].[tblCatSucursales] ([IDSucursal])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDSucursal]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDTipoNomina] FOREIGN KEY([IDTipoNomina])
REFERENCES [Nomina].[tblCatTipoNomina] ([IDTipoNomina])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDTipoNomina]
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [RH].[tblConfigAsignacionesPredeterminadas] CHECK CONSTRAINT [Fk_RHTblConfigAsignacionesPredeterminadas_IDUsuario]
GO
