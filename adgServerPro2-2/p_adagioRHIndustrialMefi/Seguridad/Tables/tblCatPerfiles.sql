USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblCatPerfiles](
	[IDPerfil] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Activo] [bit] NULL,
	[AsignarTodosLosColaboradores] [bit] NULL,
 CONSTRAINT [PK_SeguridadTblCatPerfiles_IDPerfil] PRIMARY KEY CLUSTERED 
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SeguridadTblCatPerfiles_Descripcion] UNIQUE NONCLUSTERED 
(
	[Descripcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblCatPerfiles] ADD  CONSTRAINT [D_SeguridadTblCatPerfiles_AsignarTodosLosColaboradores]  DEFAULT ((0)) FOR [AsignarTodosLosColaboradores]
GO
