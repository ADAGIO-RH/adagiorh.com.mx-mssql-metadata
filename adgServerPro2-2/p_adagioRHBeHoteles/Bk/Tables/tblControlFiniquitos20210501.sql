USE [p_adagioRHBeHoteles]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblControlFiniquitos20210501](
	[IDFiniquito] [int] IDENTITY(1,1) NOT NULL,
	[IDPeriodo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[FechaBaja] [date] NOT NULL,
	[DiasVacaciones] [decimal](18, 2) NULL,
	[DiasAguinaldo] [decimal](18, 2) NULL,
	[DiasIndemnizacion90Dias] [decimal](18, 2) NULL,
	[DiasIndemnizacion20Dias] [decimal](18, 2) NULL,
	[AplicarBaja] [bit] NOT NULL,
	[IDEStatusFiniquito] [int] NOT NULL,
	[FechaAntiguedad] [date] NULL,
	[DiasDePago] [int] NULL,
	[DiasPorPrimaAntiguedad] [int] NULL,
	[SueldoFiniquito] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
