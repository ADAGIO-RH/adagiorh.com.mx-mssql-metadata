USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TempCatConceptos](
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoConcepto] [int] NOT NULL,
	[Estatus] [bit] NOT NULL,
	[Impresion] [bit] NOT NULL,
	[IDCalculo] [int] NOT NULL,
	[CuentaAbono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaCargo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[bCantidadMonto] [bit] NOT NULL,
	[bCantidadDias] [bit] NOT NULL,
	[bCantidadVeces] [bit] NOT NULL,
	[bCantidadOtro1] [bit] NOT NULL,
	[bCantidadOtro2] [bit] NOT NULL,
	[IDCodigoSAT] [int] NULL,
	[NombreProcedure] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrdenCalculo] [int] NULL,
	[LFT] [bit] NOT NULL,
	[Personalizada] [bit] NOT NULL,
	[ConDoblePago] [bit] NOT NULL,
	[Row] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((1)) FOR [Estatus]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [Impresion]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadMonto]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadDias]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadVeces]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadOtro1]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [bCantidadOtro2]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [LFT]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [Personalizada]
GO
ALTER TABLE [Bk].[TempCatConceptos] ADD  DEFAULT ((0)) FOR [ConDoblePago]
GO
