USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblSecciones](
	[IDSeccion] [int] IDENTITY(1,1) NOT NULL,
	[IDCuestionario] [int] NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[ValorMaximo] [decimal](18, 2) NULL,
 CONSTRAINT [PK_SaludTblSecciones_IDSeccion] PRIMARY KEY CLUSTERED 
(
	[IDSeccion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblSecciones] ADD  CONSTRAINT [D_SaludTblSecciones_ValorMaximo]  DEFAULT ((0.00)) FOR [ValorMaximo]
GO
ALTER TABLE [Salud].[tblSecciones]  WITH CHECK ADD  CONSTRAINT [FK_SaludTblCuestionarios_SaludTblSecciones_IDCuestionario] FOREIGN KEY([IDCuestionario])
REFERENCES [Salud].[tblCuestionarios] ([IDCuestionario])
GO
ALTER TABLE [Salud].[tblSecciones] CHECK CONSTRAINT [FK_SaludTblCuestionarios_SaludTblSecciones_IDCuestionario]
GO
ALTER TABLE [Salud].[tblSecciones]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuario_SaludtblSecciones_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Salud].[tblSecciones] CHECK CONSTRAINT [FK_SeguridadTblUsuario_SaludtblSecciones_IDUsuario]
GO
