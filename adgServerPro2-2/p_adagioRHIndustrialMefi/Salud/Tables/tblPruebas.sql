USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblPruebas](
	[IDPrueba] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NULL,
	[RevisionTemperatura] [bit] NULL,
	[IDUsuario] [int] NOT NULL,
	[Liberado] [bit] NULL,
	[Personalizada] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_SaludTblPruebas_IDPrueba] PRIMARY KEY CLUSTERED 
(
	[IDPrueba] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SaludTblPruebas_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblPruebas] ADD  DEFAULT ((0)) FOR [RevisionTemperatura]
GO
ALTER TABLE [Salud].[tblPruebas] ADD  DEFAULT ((0)) FOR [Liberado]
GO
ALTER TABLE [Salud].[tblPruebas]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuario_SaludTblPruebas_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Salud].[tblPruebas] CHECK CONSTRAINT [FK_SeguridadTblUsuario_SaludTblPruebas_IDUsuario]
GO
