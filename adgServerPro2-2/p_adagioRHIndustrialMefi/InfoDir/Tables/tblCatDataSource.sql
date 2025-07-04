USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [InfoDir].[tblCatDataSource](
	[IDDataSource] [int] NOT NULL,
	[IDTipoItem] [int] NOT NULL,
	[IDAplicacion] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NombreProcedure] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_InfoDirtblCatDataSource_IDFuenteDato] PRIMARY KEY CLUSTERED 
(
	[IDDataSource] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [InfoDir].[tblCatDataSource]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatDataSource_AppTblCatAplicaciones_IDAplicacion] FOREIGN KEY([IDAplicacion])
REFERENCES [App].[tblCatAplicaciones] ([IDAplicacion])
GO
ALTER TABLE [InfoDir].[tblCatDataSource] CHECK CONSTRAINT [FK_InfoDirtblCatDataSource_AppTblCatAplicaciones_IDAplicacion]
GO
ALTER TABLE [InfoDir].[tblCatDataSource]  WITH CHECK ADD  CONSTRAINT [FK_InfoDirtblCatDataSource_InfoDirtblCatTipoItems_IDTipoItem] FOREIGN KEY([IDTipoItem])
REFERENCES [InfoDir].[tblCatTipoItems] ([IDTipoItem])
GO
ALTER TABLE [InfoDir].[tblCatDataSource] CHECK CONSTRAINT [FK_InfoDirtblCatDataSource_InfoDirtblCatTipoItems_IDTipoItem]
GO
