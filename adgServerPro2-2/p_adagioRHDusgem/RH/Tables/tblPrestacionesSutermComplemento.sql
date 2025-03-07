USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblPrestacionesSutermComplemento](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Antiguedad] [int] NULL,
	[DiasVacaciones] [int] NULL,
	[DiasPrimaVacacional] [int] NOT NULL,
 CONSTRAINT [Pk_RHtblPrestacionesSutermComplemento_ID_] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
