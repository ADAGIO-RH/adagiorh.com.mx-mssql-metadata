USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Intranet].[tblCatMotivoCambioDatos](
	[IDMotivoCambio] [int] NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Disponible] [bit] NULL,
 CONSTRAINT [PK_IntranettblCatMotivoCambioDatos_IDMotivoCambio] PRIMARY KEY CLUSTERED 
(
	[IDMotivoCambio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Intranet].[tblCatMotivoCambioDatos] ADD  DEFAULT ((1)) FOR [Disponible]
GO
