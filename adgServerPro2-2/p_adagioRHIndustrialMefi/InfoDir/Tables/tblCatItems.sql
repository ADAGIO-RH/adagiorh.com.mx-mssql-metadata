USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatItems](
	[IDConfItem] [int] NOT NULL,
	[IDTipoItem] [int] NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDDataSource] [int] NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfFiltrosItem] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Personalizado] [bit] NULL,
 CONSTRAINT [Pk_InfoDirtblCatItems_IDConfItem] PRIMARY KEY CLUSTERED 
(
	[IDConfItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [InfoDir].[tblCatItems]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatItems_AppTblCatAplicaciones_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [InfoDir].[tblCatItems] CHECK CONSTRAINT [FK_InfoDirtblCatItems_AppTblCatAplicaciones_IDAplicacion]
GO
ALTER TABLE [InfoDir].[tblCatItems]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatItems_InfoDirtblCatDataSource_IDDataSource] FOREIGN KEY([IDDataSource])
REFERENCES [InfoDir].[tblCatDataSource] ([IDDataSource])
GO
ALTER TABLE [InfoDir].[tblCatItems] CHECK CONSTRAINT [FK_InfoDirtblCatItems_InfoDirtblCatDataSource_IDDataSource]
GO
ALTER TABLE [InfoDir].[tblCatItems]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatItems_InfoDirtblCatTipoItems_IDTipoItem] FOREIGN KEY([IDTipoItem])
REFERENCES [InfoDir].[tblCatTipoItems] ([IDTipoItem])
GO
ALTER TABLE [InfoDir].[tblCatItems] CHECK CONSTRAINT [FK_InfoDirtblCatItems_InfoDirtblCatTipoItems_IDTipoItem]
GO
