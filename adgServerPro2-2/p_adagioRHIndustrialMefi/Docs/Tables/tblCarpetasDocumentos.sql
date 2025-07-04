USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblCarpetasDocumentos](
	[IDItem] [int] IDENTITY(1,1) NOT NULL,
	[TipoItem] [int] NOT NULL,
	[IDParent] [int] NULL,
	[Nombre] [varchar](254) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FilePath] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Version] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PalabrasClave] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Comentario] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValidoDesde] [date] NULL,
	[ValidoHasta] [date] NULL,
	[Expira] [bit] NULL,
	[DiasAntesCaducidad] [int] NULL,
	[IDTipoDocumento] [int] NULL,
	[Icono] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDAutor] [int] NULL,
	[IDPublicador] [int] NULL,
	[FechaCreacion] [datetime] NULL,
	[FechaUltimaActualizacion] [datetime] NULL,
	[Visualizar] [bit] NULL,
	[Descargar] [bit] NULL,
	[Color] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_DocsTblCarpetasDocumentos_IDItem] PRIMARY KEY CLUSTERED 
(
	[IDItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] ADD  CONSTRAINT [d_DocstblCarpetasDocumentos_Expira]  DEFAULT ((0)) FOR [Expira]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] ADD  CONSTRAINT [d_DocstblCarpetasDocumentos_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] ADD  CONSTRAINT [d_DocstblCarpetasDocumentos_FechaUltimaActualizacion]  DEFAULT (getdate()) FOR [FechaUltimaActualizacion]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] ADD  DEFAULT ((0)) FOR [Visualizar]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] ADD  DEFAULT ((0)) FOR [Descargar]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_DocsTblCatTiposDocumento_DocstblCarpetasDocumentos_IDTipoDocumento] FOREIGN KEY([IDTipoDocumento])
REFERENCES [Docs].[tblCatTiposDocumento] ([IDTipoDocumento])
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] CHECK CONSTRAINT [FK_DocsTblCatTiposDocumento_DocstblCarpetasDocumentos_IDTipoDocumento]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_DocstblCarpetasDocumentos_IDUsuario_IDAutor] FOREIGN KEY([IDAutor])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_DocstblCarpetasDocumentos_IDUsuario_IDAutor]
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadtblUsuarios_DocstblCarpetasDocumentos_IDUsuario_IDPublicador] FOREIGN KEY([IDPublicador])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblCarpetasDocumentos] CHECK CONSTRAINT [FK_SeguridadtblUsuarios_DocstblCarpetasDocumentos_IDUsuario_IDPublicador]
GO
