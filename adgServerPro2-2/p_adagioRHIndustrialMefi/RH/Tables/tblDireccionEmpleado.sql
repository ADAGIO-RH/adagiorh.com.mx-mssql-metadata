USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblDireccionEmpleado](
	[IDDireccionEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDPais] [int] NULL,
	[IDEstado] [int] NULL,
	[Estado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipio] [int] NULL,
	[Municipio] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDLocalidad] [int] NULL,
	[Localidad] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[CodigoPostal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDColonia] [int] NULL,
	[Colonia] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRuta] [int] NULL,
	[FechaIni] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_RHTblDireccionEmpleado_IDDireccionEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDDireccionEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_FechaFin] ON [RH].[tblDireccionEmpleado]
(
	[FechaFin] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_Fechaini] ON [RH].[tblDireccionEmpleado]
(
	[FechaIni] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDCodigoPostal] ON [RH].[tblDireccionEmpleado]
(
	[IDCodigoPostal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDColonia] ON [RH].[tblDireccionEmpleado]
(
	[IDColonia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDEmpleado] ON [RH].[tblDireccionEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDEstado] ON [RH].[tblDireccionEmpleado]
(
	[IDEstado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDLocalidad] ON [RH].[tblDireccionEmpleado]
(
	[IDLocalidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDMunicipio] ON [RH].[tblDireccionEmpleado]
(
	[IDMunicipio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDPais] ON [RH].[tblDireccionEmpleado]
(
	[IDPais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblDireccionEmpleado_IDRuta] ON [RH].[tblDireccionEmpleado]
(
	[IDRuta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRutasTransporte_RHtblDireccionEmpleado_IDRuta] FOREIGN KEY([IDRuta])
REFERENCES [RH].[tblCatRutasTransporte] ([IDRuta])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_RHTblCatRutasTransporte_RHtblDireccionEmpleado_IDRuta]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHtblEmpleados_RHtblDireccionEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_RHtblEmpleados_RHtblDireccionEmpleado_IDEmpleado]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblDireccionEmpleado_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblDireccionEmpleado_IDCodigoPostal]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColinias_RHtblDireccionEmpleado_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatColinias_RHtblDireccionEmpleado_IDColonia]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_RHtblDireccionEmpleado_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatEstados_RHtblDireccionEmpleado_IDEstado]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatLocalidades_RHTblDireccionEmpleado_IDLocalidad] FOREIGN KEY([IDLocalidad])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatLocalidades_RHTblDireccionEmpleado_IDLocalidad]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_RHtblDireccionEmpleado_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatMunicipios_RHtblDireccionEmpleado_IDMunicipio]
GO
ALTER TABLE [RH].[tblDireccionEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_RHtblDireccionEmpleado_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblDireccionEmpleado] CHECK CONSTRAINT [FK_SatTblCatPaises_RHtblDireccionEmpleado_IDPais]
GO
