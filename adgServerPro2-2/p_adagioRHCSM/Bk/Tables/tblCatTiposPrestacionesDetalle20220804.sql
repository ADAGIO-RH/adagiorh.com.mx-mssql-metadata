USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatTiposPrestacionesDetalle20220804](
	[IDTipoPrestacionDetalle] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPrestacion] [int] NOT NULL,
	[Antiguedad] [int] NOT NULL,
	[DiasAguinaldo] [int] NULL,
	[DiasVacaciones] [int] NULL,
	[PrimaVacacional] [decimal](18, 4) NULL,
	[PorcentajeExtra] [decimal](18, 4) NULL,
	[DiasExtras] [int] NULL,
	[Factor] [decimal](20, 4) NULL
) ON [PRIMARY]
GO
