USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatPeriodos](
	[IDPeriodo] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoNomina] [int] NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[ClavePeriodo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaInicioPago] [date] NOT NULL,
	[FechaFinPago] [date] NOT NULL,
	[FechaInicioIncidencia] [date] NOT NULL,
	[FechaFinIncidencia] [date] NOT NULL,
	[Dias] [int] NULL,
	[AnioInicio] [bit] NOT NULL,
	[AnioFin] [bit] NOT NULL,
	[MesInicio] [bit] NOT NULL,
	[MesFin] [bit] NOT NULL,
	[IDMes] [int] NOT NULL,
	[BimestreInicio] [bit] NOT NULL,
	[BimestreFin] [bit] NOT NULL,
	[Cerrado] [bit] NULL,
	[General] [bit] NULL,
	[Finiquito] [bit] NULL,
	[Especial] [bit] NULL,
	[Aguinaldo] [bit] NULL,
	[PTU] [bit] NULL,
	[DevolucionFondoAhorro] [bit] NULL,
	[Presupuesto] [bit] NULL,
 CONSTRAINT [PK_NominaTblCatPeriodos_IDPeriodo] PRIMARY KEY CLUSTERED 
(
	[IDPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblCatPeriodos_IDTipoNominaEjercicioClavePeriodo] UNIQUE NONCLUSTERED 
(
	[IDTipoNomina] ASC,
	[Ejercicio] ASC,
	[ClavePeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatPeriodos_ClavePeriodo] ON [Nomina].[tblCatPeriodos]
(
	[ClavePeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatPeriodos_Ejercicio] ON [Nomina].[tblCatPeriodos]
(
	[Ejercicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatPeriodos_IDMes] ON [Nomina].[tblCatPeriodos]
(
	[IDMes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_NominatblCatPeriodos_IDTipoNomina] ON [Nomina].[tblCatPeriodos]
(
	[IDTipoNomina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_AnioInicio]  DEFAULT ((0)) FOR [AnioInicio]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_AnioFin]  DEFAULT ((0)) FOR [AnioFin]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_MesInicio]  DEFAULT ((0)) FOR [MesInicio]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_MesFin]  DEFAULT ((0)) FOR [MesFin]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_BimestreInicio]  DEFAULT ((0)) FOR [BimestreInicio]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_BimestreFin]  DEFAULT ((0)) FOR [BimestreFin]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_Cerrado]  DEFAULT ((0)) FOR [Cerrado]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_General]  DEFAULT ((0)) FOR [General]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_Finiquito]  DEFAULT ((0)) FOR [Finiquito]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_Especial]  DEFAULT ((0)) FOR [Especial]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_Aguinaldo]  DEFAULT ((0)) FOR [Aguinaldo]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_PTU]  DEFAULT ((0)) FOR [PTU]
GO
ALTER TABLE [Nomina].[tblCatPeriodos] ADD  CONSTRAINT [DF_NominatblCatPeriodos_DevolucionFondoAhorro]  DEFAULT ((0)) FOR [DevolucionFondoAhorro]
GO
ALTER TABLE [Nomina].[tblCatPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatMeses_NominaTblCatPeriodos_IDMes] FOREIGN KEY([IDMes])
REFERENCES [Nomina].[tblCatMeses] ([IDMes])
GO
ALTER TABLE [Nomina].[tblCatPeriodos] CHECK CONSTRAINT [FK_NominaTblCatMeses_NominaTblCatPeriodos_IDMes]
GO
ALTER TABLE [Nomina].[tblCatPeriodos]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTipoNomina_NominatblCatPeriodos_IDTipoNomina] FOREIGN KEY([IDTipoNomina])
REFERENCES [Nomina].[tblCatTipoNomina] ([IDTipoNomina])
GO
ALTER TABLE [Nomina].[tblCatPeriodos] CHECK CONSTRAINT [FK_NominaTblCatTipoNomina_NominatblCatPeriodos_IDTipoNomina]
GO
