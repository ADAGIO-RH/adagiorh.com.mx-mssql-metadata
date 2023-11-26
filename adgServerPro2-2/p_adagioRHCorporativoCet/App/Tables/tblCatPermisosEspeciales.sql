USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatPermisosEspeciales](
	[IDPermiso] [int] IDENTITY(1,1) NOT NULL,
	[IDUrlParent] [int] NOT NULL,
	[Codigo] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoParent] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AppTblCatPermisosEspeciales_IDPermiso] PRIMARY KEY CLUSTERED 
(
	[IDPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatPermisosEspeciales_Codigo] ON [App].[tblCatPermisosEspeciales]
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_apptblCatPermisosEspeciales_IDUrlParent] ON [App].[tblCatPermisosEspeciales]
(
	[IDUrlParent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatPermisosEspeciales]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatUrls_AppTblCatPermisosEspeciales_IDUrl] FOREIGN KEY([IDUrlParent])
REFERENCES [App].[tblCatUrls] ([IDUrl])
GO
ALTER TABLE [App].[tblCatPermisosEspeciales] CHECK CONSTRAINT [FK_AppTblCatUrls_AppTblCatPermisosEspeciales_IDUrl]
GO
