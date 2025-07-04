USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Enrutamiento].[tblRutaUnidadProceso](
	[IDRutaUnidadProceso] [int] IDENTITY(1,1) NOT NULL,
	[IDUnidad] [int] NOT NULL,
	[IDCatRuta] [int] NOT NULL,
	[Ruta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCatTipoProceso] [int] NOT NULL,
	[TipoProceso] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRutaStep] [int] NOT NULL,
	[IDCatTipoStep] [int] NOT NULL,
	[TipoStep] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NOT NULL,
	[Completado] [bit] NULL,
	[FechaHoraCompletado] [datetime] NULL,
 CONSTRAINT [PK_EnrutamientoTblRutaUnidadProceso_IDRutaUnidadProceso] PRIMARY KEY CLUSTERED 
(
	[IDRutaUnidadProceso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Enrutamiento].[tblRutaUnidadProceso] ADD  CONSTRAINT [d_EnrutamientoTblRutaUnidadProceso_Completado]  DEFAULT ((0)) FOR [Completado]
GO
ALTER TABLE [Enrutamiento].[tblRutaUnidadProceso]  WITH CHECK ADD  CONSTRAINT [FK_EnrutamientoTblUnidadProceso_EnrutamientoTblRutaUnidadProceso_IDUnidad] FOREIGN KEY([IDUnidad])
REFERENCES [Enrutamiento].[tblUnidadProceso] ([IDUnidad])
GO
ALTER TABLE [Enrutamiento].[tblRutaUnidadProceso] CHECK CONSTRAINT [FK_EnrutamientoTblUnidadProceso_EnrutamientoTblRutaUnidadProceso_IDUnidad]
GO
