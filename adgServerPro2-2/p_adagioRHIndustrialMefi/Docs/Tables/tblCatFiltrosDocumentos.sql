USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblCatFiltrosDocumentos](
	[IDCatFiltroDocumento] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuarioCreo] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [Pk_DocstblCatFiltrosDocumentos_IDCatFiltroDocumento] PRIMARY KEY CLUSTERED 
(
	[IDCatFiltroDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblCatFiltrosDocumentos] ADD  CONSTRAINT [D_DocstblCatFiltrosDocumentos_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Docs].[tblCatFiltrosDocumentos]  WITH CHECK ADD  CONSTRAINT [Fk_DocsTblCarpetasDocumentos_DocstblCatFiltrosDocumentos_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Docs].[tblCarpetasDocumentos] ([IDItem])
ON DELETE CASCADE
GO
ALTER TABLE [Docs].[tblCatFiltrosDocumentos] CHECK CONSTRAINT [Fk_DocsTblCarpetasDocumentos_DocstblCatFiltrosDocumentos_IDDocumento]
GO
ALTER TABLE [Docs].[tblCatFiltrosDocumentos]  WITH CHECK ADD  CONSTRAINT [Fk_DocstblCatFiltrosDocumentos_SeguridadTblUsuarios_IDUsuarioCreo] FOREIGN KEY([IDUsuarioCreo])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblCatFiltrosDocumentos] CHECK CONSTRAINT [Fk_DocstblCatFiltrosDocumentos_SeguridadTblUsuarios_IDUsuarioCreo]
GO
