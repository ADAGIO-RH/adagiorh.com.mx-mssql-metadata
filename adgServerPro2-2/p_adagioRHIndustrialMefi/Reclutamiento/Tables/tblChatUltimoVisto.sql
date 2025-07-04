USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblChatUltimoVisto](
	[IDChatUltimoVisto] [int] IDENTITY(1,1) NOT NULL,
	[IDSala] [int] NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDTipoUsuario] [int] NOT NULL,
	[UltimoIDChatMensaje] [int] NOT NULL,
 CONSTRAINT [PK_ReclutamientotblChatUltimoVisto_IDChatMensaje] PRIMARY KEY CLUSTERED 
(
	[IDChatUltimoVisto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblChatUltimoVisto]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblChatUltimoVisto_ReclutamientotblChatSala_IDSala] FOREIGN KEY([IDSala])
REFERENCES [Reclutamiento].[tblChatSala] ([IDSala])
GO
ALTER TABLE [Reclutamiento].[tblChatUltimoVisto] CHECK CONSTRAINT [FK_ReclutamientotblChatUltimoVisto_ReclutamientotblChatSala_IDSala]
GO
ALTER TABLE [Reclutamiento].[tblChatUltimoVisto]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblChatUltimoVisto_ReclutamientotblChatTipoUsuario_IDTipoUsuario] FOREIGN KEY([IDTipoUsuario])
REFERENCES [Reclutamiento].[tblChatTipoUsuario] ([IDTipoUsuario])
GO
ALTER TABLE [Reclutamiento].[tblChatUltimoVisto] CHECK CONSTRAINT [FK_ReclutamientotblChatUltimoVisto_ReclutamientotblChatTipoUsuario_IDTipoUsuario]
GO
