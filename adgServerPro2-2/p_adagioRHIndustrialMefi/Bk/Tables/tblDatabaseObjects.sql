USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblDatabaseObjects](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Definition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Tipo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[BKID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaCreacion] [datetime] NULL,
 CONSTRAINT [Pk_BkTblDatabaseObjects_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 20, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bk].[tblDatabaseObjects] ADD  CONSTRAINT [D_BkTblDatabaseObjects_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
