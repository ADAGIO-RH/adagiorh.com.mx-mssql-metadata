USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatModulos](
	[IDModulo] [int] IDENTITY(1,1) NOT NULL,
	[IDArea] [int] NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
 CONSTRAINT [PK_ApptblCatModulos_IDModulo] PRIMARY KEY CLUSTERED 
(
	[IDModulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_APPtblCatModulos_IDArea] ON [App].[tblCatModulos]
(
	[IDArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatModulos]  WITH CHECK ADD  CONSTRAINT [FK_AppTblCatArea_AppTblCatModulos_IDArea] FOREIGN KEY([IDArea])
REFERENCES [App].[tblCatAreas] ([IDArea])
GO
ALTER TABLE [App].[tblCatModulos] CHECK CONSTRAINT [FK_AppTblCatArea_AppTblCatModulos_IDArea]
GO
