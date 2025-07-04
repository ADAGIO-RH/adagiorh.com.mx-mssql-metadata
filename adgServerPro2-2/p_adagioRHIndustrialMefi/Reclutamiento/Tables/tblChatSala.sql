USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblChatSala](
	[IDSala] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoSala] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
 CONSTRAINT [PK_ReclutamientotblChatSala_IDSala] PRIMARY KEY CLUSTERED 
(
	[IDSala] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblChatSala]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientotblChatSala_ReclutamientotblTipoSala_IDTipoSala] FOREIGN KEY([IDTipoSala])
REFERENCES [Reclutamiento].[tblChatTiposSala] ([IDTipoSala])
GO
ALTER TABLE [Reclutamiento].[tblChatSala] CHECK CONSTRAINT [FK_ReclutamientotblChatSala_ReclutamientotblTipoSala_IDTipoSala]
GO
