USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblDenuncias](
	[IDDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoDenuncia] [int] NULL,
	[IDEmpleado] [int] NULL,
	[esAnonima] [bit] NULL,
	[Fecha] [datetime] NULL,
	[Titulo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreDenunciado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatus] [int] NULL,
 CONSTRAINT [Pk_Norma035TblDenunciass_IDDenuncia] PRIMARY KEY CLUSTERED 
(
	[IDDenuncia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
