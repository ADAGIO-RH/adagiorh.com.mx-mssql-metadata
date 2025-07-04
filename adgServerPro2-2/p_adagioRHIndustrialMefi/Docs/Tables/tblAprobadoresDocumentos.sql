USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Docs].[tblAprobadoresDocumentos](
	[IDAprobadorDocumento] [int] IDENTITY(1,1) NOT NULL,
	[IDDocumento] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Aprobacion] [int] NOT NULL,
	[Observacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAprobacion] [datetime] NULL,
	[Secuencia] [int] NOT NULL,
 CONSTRAINT [PK_DocstblAprobadoresDocumentos_IDAprobadorDocumento] PRIMARY KEY CLUSTERED 
(
	[IDAprobadorDocumento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_DocsTblAprobadoresDocumentos_IDDocumento_IDUsuario_Secuencia] UNIQUE NONCLUSTERED 
(
	[IDDocumento] ASC,
	[IDUsuario] ASC,
	[Secuencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Docs].[tblAprobadoresDocumentos] ADD  DEFAULT ((0)) FOR [Aprobacion]
GO
ALTER TABLE [Docs].[tblAprobadoresDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_DocstblCarpetasDocumentos_DocstblAprobadoresDocumentos_IDItem_IDDocumento] FOREIGN KEY([IDDocumento])
REFERENCES [Docs].[tblCarpetasDocumentos] ([IDItem])
GO
ALTER TABLE [Docs].[tblAprobadoresDocumentos] CHECK CONSTRAINT [FK_DocstblCarpetasDocumentos_DocstblAprobadoresDocumentos_IDItem_IDDocumento]
GO
ALTER TABLE [Docs].[tblAprobadoresDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_DocstblAprobadoresDocumentos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Docs].[tblAprobadoresDocumentos] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_DocstblAprobadoresDocumentos_IDUsuario]
GO
