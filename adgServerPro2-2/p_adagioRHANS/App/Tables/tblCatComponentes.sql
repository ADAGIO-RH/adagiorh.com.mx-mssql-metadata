USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatComponentes](
	[IDComponente] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Nombre] [App].[MDName] NOT NULL,
	[Descripcion] [App].[XLDescription] NULL,
 CONSTRAINT [Pk_AppTblCatComponentes_IDComponente] PRIMARY KEY CLUSTERED 
(
	[IDComponente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
