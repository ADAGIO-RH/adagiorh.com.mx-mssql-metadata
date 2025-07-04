USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comedor].[tblCatRestaurantes](
	[IDRestaurante] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Disponible] [bit] NULL,
 CONSTRAINT [Pk_ComedorTblCatRestaurantes_IDRestaurante] PRIMARY KEY CLUSTERED 
(
	[IDRestaurante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Comedor].[tblCatRestaurantes] ADD  CONSTRAINT [D_ComedorTblCatRestaurantes_Disponible]  DEFAULT ((1)) FOR [Disponible]
GO
