USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblChatMensajes](
	[IDChatMensaje] [int] IDENTITY(1,1) NOT NULL,
	[IDSala] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDTipoUsuario] [int] NOT NULL,
	[Mensaje] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHora] [datetime] NULL,
 CONSTRAINT [PK_ReclutamientotblChatMensajes_IDChatMensaje] PRIMARY KEY CLUSTERED 
(
	[IDChatMensaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblChatMensajes] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Reclutamiento].[tblChatMensajes]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblChatMensajes_ReclutamientotblChatSala_IDSala] FOREIGN KEY([IDSala])
REFERENCES [Reclutamiento].[tblChatSala] ([IDSala])
GO
ALTER TABLE [Reclutamiento].[tblChatMensajes] CHECK CONSTRAINT [FK_ReclutamientotblChatMensajes_ReclutamientotblChatSala_IDSala]
GO
ALTER TABLE [Reclutamiento].[tblChatMensajes]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblChatMensajes_ReclutamientotblChatTipoUsuario_IDTipoUsuario] FOREIGN KEY([IDTipoUsuario])
REFERENCES [Reclutamiento].[tblChatTipoUsuario] ([IDTipoUsuario])
GO
ALTER TABLE [Reclutamiento].[tblChatMensajes] CHECK CONSTRAINT [FK_ReclutamientotblChatMensajes_ReclutamientotblChatTipoUsuario_IDTipoUsuario]
GO
