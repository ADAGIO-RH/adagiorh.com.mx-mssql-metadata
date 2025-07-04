USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblCatGrupos](
	[IDCatGrupo] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCatTipoGrupo] [int] NOT NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[RespuestaGrupo] [bit] NULL,
	[Orden] [int] NULL,
	[uuid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[uuidDependencia] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Nota] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_Norma35TblCatGrupos_IDCatGrupo] PRIMARY KEY CLUSTERED 
(
	[IDCatGrupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblCatGrupos]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblCatTiposGrupos_Norma35TblCatGrupos_IDCatTipoGrupo] FOREIGN KEY([IDCatTipoGrupo])
REFERENCES [Norma35].[tblCatTiposGrupos] ([IDCatTipoGrupo])
GO
ALTER TABLE [Norma35].[tblCatGrupos] CHECK CONSTRAINT [FK_Norma35TblCatTiposGrupos_Norma35TblCatGrupos_IDCatTipoGrupo]
GO
