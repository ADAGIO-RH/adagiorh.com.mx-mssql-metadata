USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatConceptosCancun](
	[IDConcepto] [float] NULL,
	[Codigo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDTipoConcepto] [float] NULL,
	[Estatus] [float] NULL,
	[Impresion] [float] NULL,
	[IDCalculo] [float] NULL,
	[CuentaAbono] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CuentaCargo] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[bCantidadMonto] [float] NULL,
	[bCantidadDias] [float] NULL,
	[bCantidadVeces] [float] NULL,
	[bCantidadOtro1] [float] NULL,
	[bCantidadOtro2] [float] NULL,
	[IDCodigoSAT] [float] NULL,
	[NombreProcedure] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OrdenCalculo] [float] NULL,
	[LFT] [float] NULL,
	[Personalizada] [float] NULL,
	[ConDoblePago] [float] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
