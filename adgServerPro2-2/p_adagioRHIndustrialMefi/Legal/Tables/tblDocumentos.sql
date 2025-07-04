USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Legal].[tblDocumentos](
	[IDDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [datetime] NULL,
	[IDTipoDocumento] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_LegaltblDocumentos_IDDocumento] PRIMARY KEY CLUSTERED 
(
	[IDDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Legal].[tblDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblDocumentos_LegaltblCatTiposDocumentos_IDTipoDocumento] FOREIGN KEY([IDTipoDocumento])
REFERENCES [Legal].[tblCatTiposDocumentos] ([IDTipoDocumento])
GO
ALTER TABLE [Legal].[tblDocumentos] CHECK CONSTRAINT [FK_LegaltblDocumentos_LegaltblCatTiposDocumentos_IDTipoDocumento]
GO
ALTER TABLE [Legal].[tblDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblDocumentos_SeguridadtblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Legal].[tblDocumentos] CHECK CONSTRAINT [FK_LegaltblDocumentos_SeguridadtblUsuarios_IDUsuario]
GO
