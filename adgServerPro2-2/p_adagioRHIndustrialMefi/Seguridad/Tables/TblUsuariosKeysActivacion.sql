USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[TblUsuariosKeysActivacion](
	[IDUsuarioKeysActivacion] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[ActivationKey] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AvaibleUntil] [date] NOT NULL,
	[Activo] [bit] NOT NULL,
	[CreationDate] [datetime] NULL,
	[ActivationDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IDUsuarioKeysActivacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_TblUsuariosKeysActivacion_ActivactionKey] UNIQUE NONCLUSTERED 
(
	[ActivationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[TblUsuariosKeysActivacion] ADD  CONSTRAINT [D_TblUsuariosKeysActivacion_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [Seguridad].[TblUsuariosKeysActivacion] ADD  CONSTRAINT [D_TblAsuntosTickets_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
GO
ALTER TABLE [Seguridad].[TblUsuariosKeysActivacion]  WITH CHECK ADD  CONSTRAINT [Fk_TblUsuariosKeysActivacion_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [Seguridad].[TblUsuariosKeysActivacion] CHECK CONSTRAINT [Fk_TblUsuariosKeysActivacion_IDUsuario]
GO
