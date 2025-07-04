USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Legal].[tblFirmas](
	[IDFirma] [int] IDENTITY(1,1) NOT NULL,
	[Firma] [bit] NOT NULL,
	[Fecha] [datetime] NULL,
	[IDDocumento] [int] NOT NULL,
	[IDVersionDocumento] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_LegaltblFirmas_IDFirma] PRIMARY KEY CLUSTERED 
(
	[IDFirma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Legal].[tblFirmas]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblFirmas_LegaltblDocumentos_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Legal].[tblDocumentos] ([IDDocumento])
GO
ALTER TABLE [Legal].[tblFirmas] CHECK CONSTRAINT [FK_LegaltblFirmas_LegaltblDocumentos_IDDocumento]
GO
ALTER TABLE [Legal].[tblFirmas]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblFirmas_LegaltblVersionesDocumentos_IDVersion] FOREIGN KEY([IDVersionDocumento])
REFERENCES [Legal].[tblVersionesDocumentos] ([IDVersionDocumento])
GO
ALTER TABLE [Legal].[tblFirmas] CHECK CONSTRAINT [FK_LegaltblFirmas_LegaltblVersionesDocumentos_IDVersion]
GO
ALTER TABLE [Legal].[tblFirmas]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblFirmas_SeguridadtblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Legal].[tblFirmas] CHECK CONSTRAINT [FK_LegaltblFirmas_SeguridadtblUsuarios_IDUsuario]
GO
