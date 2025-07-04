USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblUsuarios](
	[IDUsuario] [int] IDENTITY(1,1) NOT NULL,
	[Cuenta] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Password] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPreferencia] [int] NULL,
	[Nombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Apellido] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activo] [bit] NULL,
	[IDPerfil] [int] NOT NULL,
	[IDEmpleado] [int] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Supervisor] [bit] NULL,
	[Bloqueado] [bit] NULL,
	[ResetPassword] [int] NULL,
 CONSTRAINT [Pk_SeguridadTblUsuarios_IDUsuario] PRIMARY KEY CLUSTERED 
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_SeguridadTblUsuarios_Cuenta] UNIQUE NONCLUSTERED 
(
	[Cuenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadTblUsuarios_Activo] ON [Seguridad].[tblUsuarios]
(
	[Activo] ASC
)
INCLUDE([IDUsuario],[IDEmpleado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblUsuarios_Cuenta] ON [Seguridad].[tblUsuarios]
(
	[Cuenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblUsuarios_IDEmpleado] ON [Seguridad].[tblUsuarios]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_SeguridadtblUsuarios_IDPerfil] ON [Seguridad].[tblUsuarios]
(
	[IDPerfil] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_SeguridadTblUsuarios_Email] ON [Seguridad].[tblUsuarios]
(
	[Email] ASC
)
WHERE ([Email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_SeguridadTblUsuarios_IDEmpleado] ON [Seguridad].[tblUsuarios]
(
	[IDEmpleado] ASC
)
WHERE ([IDEmpleado] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblUsuarios] ADD  CONSTRAINT [D_SeguridadTblUsuarios_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [Seguridad].[tblUsuarios] ADD  CONSTRAINT [D_SeguridadTblUsuarios_Supervisor]  DEFAULT ((0)) FOR [Supervisor]
GO
ALTER TABLE [Seguridad].[tblUsuarios] ADD  CONSTRAINT [D_SeguridadTblUsuarios_Bloquedo]  DEFAULT ((0)) FOR [Bloqueado]
GO
ALTER TABLE [Seguridad].[tblUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblEmpleados_SeguridadTblUsuairos_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [Seguridad].[tblUsuarios] CHECK CONSTRAINT [Fk_RHTblEmpleados_SeguridadTblUsuairos_IDEmpleado]
GO
ALTER TABLE [Seguridad].[tblUsuarios]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadTblUsuarios_IDPerfil] FOREIGN KEY([IDPerfil])
REFERENCES [Seguridad].[tblCatPerfiles] ([IDPerfil])
GO
ALTER TABLE [Seguridad].[tblUsuarios] CHECK CONSTRAINT [FK_SeguridadTblCatPerfiles_SeguridadTblUsuarios_IDPerfil]
GO
ALTER TABLE [Seguridad].[tblUsuarios]  WITH CHECK ADD  CONSTRAINT [Fk_SeguridadTblUsuarios_IDPreferencia] FOREIGN KEY([IDPreferencia])
REFERENCES [App].[tblPreferencias] ([IDPreferencia])
GO
ALTER TABLE [Seguridad].[tblUsuarios] CHECK CONSTRAINT [Fk_SeguridadTblUsuarios_IDPreferencia]
GO
ALTER TABLE [Seguridad].[tblUsuarios]  WITH CHECK ADD  CONSTRAINT [Ck_SeguridadTblUsuarios_ValidarEmail] CHECK  (([Email] IS NULL OR [Email] like '%_@__%.__%'))
GO
ALTER TABLE [Seguridad].[tblUsuarios] CHECK CONSTRAINT [Ck_SeguridadTblUsuarios_ValidarEmail]
GO
