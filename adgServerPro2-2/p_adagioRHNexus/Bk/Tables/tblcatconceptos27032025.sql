USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblcatconceptos27032025](
	[IDConcepto] [int] IDENTITY(1,1) NOT NULL,
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
	[OrdenCalculo] [int] NOT NULL,
	[LFT] [bit] NOT NULL,
	[Personalizada] [bit] NOT NULL,
	[ConDoblePago] [bit] NOT NULL,
	[IDPais] [int] NULL,
	[Presupuesto] [bit] NULL
) ON [PRIMARY]
GO
