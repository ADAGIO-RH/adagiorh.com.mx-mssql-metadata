USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Legal].[tblVersionesDocumentos](
	[IDVersionDocumento] [int] IDENTITY(1,1) NOT NULL,
	[Template] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaActualizacion] [datetime] NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[IDEstatus] [int] NOT NULL,
 CONSTRAINT [Pk_LegaltblVersionesDocumentos_IDVersionDocumento] PRIMARY KEY CLUSTERED 
(
	[IDVersionDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Legal].[tblVersionesDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblVersionesDocumentos_LegaltblCatEstatus_IDEstatus] FOREIGN KEY([IDEstatus])
REFERENCES [Legal].[tblCatEstatus] ([IDEstatus])
GO
ALTER TABLE [Legal].[tblVersionesDocumentos] CHECK CONSTRAINT [FK_LegaltblVersionesDocumentos_LegaltblCatEstatus_IDEstatus]
GO
ALTER TABLE [Legal].[tblVersionesDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_LegaltblVersionesDocumentos_LegaltblDocumentos_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Legal].[tblDocumentos] ([IDDocumento])
GO
ALTER TABLE [Legal].[tblVersionesDocumentos] CHECK CONSTRAINT [FK_LegaltblVersionesDocumentos_LegaltblDocumentos_IDDocumento]
GO
