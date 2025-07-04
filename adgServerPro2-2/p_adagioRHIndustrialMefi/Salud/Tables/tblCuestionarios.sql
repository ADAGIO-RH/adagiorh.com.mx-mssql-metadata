USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblCuestionarios](
	[IDCuestionario] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[isDefault] [bit] NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_SaludtblCuestionarios_IDCuestionario] PRIMARY KEY CLUSTERED 
(
	[IDCuestionario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblCuestionarios] ADD  DEFAULT ((0)) FOR [TipoReferencia]
GO
ALTER TABLE [Salud].[tblCuestionarios] ADD  DEFAULT ((0)) FOR [IDReferencia]
GO
ALTER TABLE [Salud].[tblCuestionarios] ADD  DEFAULT ((0)) FOR [isDefault]
GO
ALTER TABLE [Salud].[tblCuestionarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuario_SaludTblCuestionarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Salud].[tblCuestionarios] CHECK CONSTRAINT [FK_SeguridadTblUsuario_SaludTblCuestionarios_IDUsuario]
GO
