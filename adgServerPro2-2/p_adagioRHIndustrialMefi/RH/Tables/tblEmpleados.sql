USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEmpleados](
	[IDEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[ClaveEmpleado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMSS] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SegundoNombre] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Paterno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Materno] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDMunicipioNacimiento] [int] NULL,
	[IDEstadoNacimiento] [int] NULL,
	[IDPaisNacimiento] [int] NULL,
	[FechaNacimiento] [date] NULL,
	[IDEstadoCivil] [int] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEscolaridad] [int] NULL,
	[DescripcionEscolaridad] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaPrimerIngreso] [date] NULL,
	[FechaIngreso] [date] NULL,
	[FechaAntiguedad] [date] NULL,
	[Sindicalizado] [bit] NULL,
	[IDJornadaLaboral] [int] NULL,
	[UMF] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaContable] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPreferencia] [int] NULL,
	[Password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoRegimen] [int] NULL,
	[MunicipioNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EstadoNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PaisNacimiento] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDInstitucion] [int] NULL,
	[IDProbatorio] [int] NULL,
	[IDAfore] [int] NULL,
	[IDLocalidadNacimiento] [int] NULL,
	[LocalidadNacimiento] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PermiteChecar] [bit] NOT NULL,
	[RequiereChecar] [bit] NOT NULL,
	[PagarTiempoExtra] [bit] NOT NULL,
	[PagarPrimaDominical] [bit] NOT NULL,
	[PagarDescansoLaborado] [bit] NOT NULL,
	[PagarFestivoLaborado] [bit] NOT NULL,
	[DomicilioFiscal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[CodigoLector] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoJornada] [int] NULL,
	[RequiereTransporte] [bit] NULL,
 CONSTRAINT [PK_tblEmpleado_IDEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_tblEmpleados_Nomina] UNIQUE NONCLUSTERED 
(
	[ClaveEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_RHTblEmpleados_ClaveEmpleado] ON [RH].[tblEmpleados]
(
	[ClaveEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDAfore] ON [RH].[tblEmpleados]
(
	[IDAfore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDEscolaridad] ON [RH].[tblEmpleados]
(
	[IDEscolaridad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDEstadoCivil] ON [RH].[tblEmpleados]
(
	[IDEstadoCivil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDEstadoNacimiento] ON [RH].[tblEmpleados]
(
	[IDEstadoNacimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDInstitucion] ON [RH].[tblEmpleados]
(
	[IDInstitucion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDJornadaLaboral] ON [RH].[tblEmpleados]
(
	[IDJornadaLaboral] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDLocalidadNacimiento] ON [RH].[tblEmpleados]
(
	[IDLocalidadNacimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDMunicipioNacimiento] ON [RH].[tblEmpleados]
(
	[IDMunicipioNacimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDPaisNacimiento] ON [RH].[tblEmpleados]
(
	[IDPaisNacimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDProbatorio] ON [RH].[tblEmpleados]
(
	[IDProbatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_IDTipoRegimen] ON [RH].[tblEmpleados]
(
	[IDTipoRegimen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_Materno] ON [RH].[tblEmpleados]
(
	[Materno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_Nombre] ON [RH].[tblEmpleados]
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_NombreCompleto] ON [RH].[tblEmpleados]
(
	[Nombre] ASC,
	[SegundoNombre] ASC,
	[Paterno] ASC,
	[Materno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_Paterno] ON [RH].[tblEmpleados]
(
	[Paterno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_RHtblEmpleados_SegundoNombre] ON [RH].[tblEmpleados]
(
	[SegundoNombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_RHTblEmpleados_CodigoLector] ON [RH].[tblEmpleados]
(
	[CodigoLector] ASC
)
WHERE ([CodigoLector] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_PermiteChecar]  DEFAULT ((1)) FOR [PermiteChecar]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_RequiereChecar]  DEFAULT ((1)) FOR [RequiereChecar]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_PagarTiempoExtra]  DEFAULT ((1)) FOR [PagarTiempoExtra]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_PagarPrimaDominical]  DEFAULT ((1)) FOR [PagarPrimaDominical]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_PagarDescansoLaborado]  DEFAULT ((1)) FOR [PagarDescansoLaborado]
GO
ALTER TABLE [RH].[tblEmpleados] ADD  CONSTRAINT [DF_RHTblEmpleados_PagarFestivoLaborado]  DEFAULT ((1)) FOR [PagarFestivoLaborado]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblCatTipoJornada_RHTblEmpleados_IDTipoJornada] FOREIGN KEY([IDTipoJornada])
REFERENCES [IMSS].[tblCatTipoJornada] ([IDTipoJornada])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_IMSStblCatTipoJornada_RHTblEmpleados_IDTipoJornada]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatAfores_RHTblEmpleados_IDAfore] FOREIGN KEY([IDAfore])
REFERENCES [RH].[tblCatAfores] ([IDAfore])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_RHTblCatAfores_RHTblEmpleados_IDAfore]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblEmpleados_IDMunicipioNacimiento] FOREIGN KEY([IDMunicipioNacimiento])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblEmpleados_IDMunicipioNacimiento]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_RHtblEmpleados_IDEstadoNacimiento] FOREIGN KEY([IDEstadoNacimiento])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SatTblCatEstados_RHtblEmpleados_IDEstadoNacimiento]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatLocalidades_RHTblEmpleados_IDLocalidad] FOREIGN KEY([IDLocalidadNacimiento])
REFERENCES [Sat].[tblCatLocalidades] ([IDLocalidad])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SatTblCatLocalidades_RHTblEmpleados_IDLocalidad]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_RHtblEmpleados_IDPaisNacimiento] FOREIGN KEY([IDPaisNacimiento])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SatTblCatPaises_RHtblEmpleados_IDPaisNacimiento]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatRegimenesFiscales_RHTblEmpleados_IDRegimenFiscal] FOREIGN KEY([IDRegimenFiscal])
REFERENCES [Sat].[tblCatRegimenesFiscales] ([IDRegimenFiscal])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SatTblCatRegimenesFiscales_RHTblEmpleados_IDRegimenFiscal]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_SATtblCatTiposJornada_RHtblCatEmpleados_IDTipoJornada] FOREIGN KEY([IDJornadaLaboral])
REFERENCES [Sat].[tblCatTiposJornada] ([IDTipoJornada])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [Fk_SATtblCatTiposJornada_RHtblCatEmpleados_IDTipoJornada]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_SATtblCatTiposRegimen_RHtblEmpleados_IDTipoRegimen] FOREIGN KEY([IDTipoRegimen])
REFERENCES [Sat].[tblCatTiposRegimen] ([IDTipoRegimen])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_SATtblCatTiposRegimen_RHtblEmpleados_IDTipoRegimen]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_STPStblCatEstudios_IDEstudio] FOREIGN KEY([IDEscolaridad])
REFERENCES [STPS].[tblCatEstudios] ([IDEstudio])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [Fk_STPStblCatEstudios_IDEstudio]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_STPStblCatInstituciones_RHTblEmpleados_IDInstitucion] FOREIGN KEY([IDInstitucion])
REFERENCES [STPS].[tblCatInstituciones] ([IDInstitucion])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_STPStblCatInstituciones_RHTblEmpleados_IDInstitucion]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [FK_STPStblCatProbatorios_RHTblEmpleados_IDProbatorio] FOREIGN KEY([IDProbatorio])
REFERENCES [STPS].[tblCatProbatorios] ([IDProbatorio])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [FK_STPStblCatProbatorios_RHTblEmpleados_IDProbatorio]
GO
ALTER TABLE [RH].[tblEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_tblEmpleados_IDPreferencia] FOREIGN KEY([IDPreferencia])
REFERENCES [App].[tblPreferencias] ([IDPreferencia])
GO
ALTER TABLE [RH].[tblEmpleados] CHECK CONSTRAINT [Fk_tblEmpleados_IDPreferencia]
GO
