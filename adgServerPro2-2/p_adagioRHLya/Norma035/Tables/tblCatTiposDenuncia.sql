USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma035].[tblCatTiposDenuncia](
	[IDTipoDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PermitirAnonimo] [bit] NOT NULL,
	[Estatus] [bit] NOT NULL,
	[UltimaActualizacion] [datetime] NOT NULL,
 CONSTRAINT [Pk_Norma035TblCatTiposDenuncias_IDTipoDenuncia] PRIMARY KEY CLUSTERED 
(
	[IDTipoDenuncia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
