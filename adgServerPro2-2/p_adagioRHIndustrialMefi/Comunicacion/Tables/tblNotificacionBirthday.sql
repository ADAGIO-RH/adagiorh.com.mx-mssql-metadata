USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comunicacion].[tblNotificacionBirthday](
	[IDNotificacionBirthday] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Asunto] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Body] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Actual] [bit] NOT NULL,
	[IDIdioma] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDUsuario] [int] NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_ComunicacionTblNotificacionBirthday_IDNotificacionBirthday] PRIMARY KEY CLUSTERED 
(
	[IDNotificacionBirthday] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comunicacion].[tblNotificacionBirthday] ADD  CONSTRAINT [D_ComunicacionTblNotificacionBrithday_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [Comunicacion].[tblNotificacionBirthday]  WITH CHECK ADD  CONSTRAINT [Fk_ComunicacionTblNotificacionBirthday_AppTblIdiomas_IDIdioma] FOREIGN KEY([IDIdioma])
REFERENCES [App].[tblIdiomas] ([IDIdioma])
GO
ALTER TABLE [Comunicacion].[tblNotificacionBirthday] CHECK CONSTRAINT [Fk_ComunicacionTblNotificacionBirthday_AppTblIdiomas_IDIdioma]
GO
ALTER TABLE [Comunicacion].[tblNotificacionBirthday]  WITH CHECK ADD  CONSTRAINT [Fk_ComunicacionTblNotificacionBirthday_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Comunicacion].[tblNotificacionBirthday] CHECK CONSTRAINT [Fk_ComunicacionTblNotificacionBirthday_SeguridadTblUsuarios_IDUsuario]
GO
