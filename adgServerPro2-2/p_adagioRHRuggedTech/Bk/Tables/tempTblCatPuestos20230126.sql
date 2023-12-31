USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tempTblCatPuestos20230126](
	[IDPuesto] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionPuesto] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SueldoBase] [money] NULL,
	[TopeSalarial] [money] NULL,
	[NivelSalarial] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDOcupacion] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
