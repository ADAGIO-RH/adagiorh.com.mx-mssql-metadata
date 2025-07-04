USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seguridad].[tblTokens](
	[IDToken] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoToken] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Token] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Activo] [bit] NOT NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_SeguridadTblTokens_IDToken] PRIMARY KEY CLUSTERED 
(
	[IDToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Seguridad].[tblTokens] ADD  CONSTRAINT [d_SeguridadTblTokens_Activo]  DEFAULT ((0)) FOR [Activo]
GO
ALTER TABLE [Seguridad].[tblTokens]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTipoToken_SeguridadTblTokens_IDTipoToken] FOREIGN KEY([IDTipoToken])
REFERENCES [Seguridad].[tblCatTipoToken] ([IDTipoToken])
GO
ALTER TABLE [Seguridad].[tblTokens] CHECK CONSTRAINT [FK_SeguridadTblCatTipoToken_SeguridadTblTokens_IDTipoToken]
GO
ALTER TABLE [Seguridad].[tblTokens]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTblTokens_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Seguridad].[tblTokens] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_SeguridadTblTokens_IDUsuario]
GO
