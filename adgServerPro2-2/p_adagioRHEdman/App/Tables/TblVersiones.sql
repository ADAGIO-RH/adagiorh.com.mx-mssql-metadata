USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[TblVersiones](
	[Version] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [Pk_AppVersiones_Version] PRIMARY KEY CLUSTERED 
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[TblVersiones] ADD  CONSTRAINT [D_AppVersiones_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
