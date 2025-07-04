USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblAdgFiles](
	[IDAdgFile] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[extension] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[pathFile] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[relativePath] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[downloadURL] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[requiereAutenticacion] [bit] NULL,
 CONSTRAINT [Pk_AppTblAdgFiles_IDAdgFile] PRIMARY KEY CLUSTERED 
(
	[IDAdgFile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblAdgFiles] ADD  CONSTRAINT [D_AppTblAdgFiles_requiereAutenticacion]  DEFAULT (CONVERT([bit],(0))) FOR [requiereAutenticacion]
GO
