USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblTabuladorSalarial](
	[IDNivelSalarial] [int] IDENTITY(1,1) NOT NULL,
	[Nivel] [int] NOT NULL,
	[Minimo] [decimal](18, 2) NOT NULL,
	[Q1] [decimal](18, 2) NOT NULL,
	[Medio] [decimal](18, 2) NOT NULL,
	[Q3] [decimal](18, 2) NOT NULL,
	[Maximo] [decimal](18, 2) NOT NULL,
	[Amplitud] [decimal](18, 2) NOT NULL,
	[Progresion] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_RHTblTabuladorSalarial_IDNivelSalarial] PRIMARY KEY CLUSTERED 
(
	[IDNivelSalarial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
