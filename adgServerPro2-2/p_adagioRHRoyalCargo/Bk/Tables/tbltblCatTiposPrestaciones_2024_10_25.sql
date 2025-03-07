USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tbltblCatTiposPrestaciones_2024_10_25](
	[IDTipoPrestacion] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfianzaSindical] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sindical] [bit] NULL,
	[PorcentajeFondoAhorro] [decimal](10, 3) NULL,
	[IDsConceptosFondoAhorro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ToparFondoAhorro] [bit] NULL,
	[_Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
