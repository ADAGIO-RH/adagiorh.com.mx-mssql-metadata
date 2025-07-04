USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblTipoDenunciasNotificaciones](
	[IDTipoDenunciasNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoDenuncia] [int] NULL,
	[IDUsuario] [int] NULL,
	[EmailAsignado] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_Norma35tblTipoDenunciasNotificaciones_IDTipoDenunciasNotifiacion] PRIMARY KEY CLUSTERED 
(
	[IDTipoDenunciasNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblTipoDenunciasNotificaciones_Norma35TblCatTiposDenuncias_IDTipoDenuncia] FOREIGN KEY([IDTipoDenuncia])
REFERENCES [Norma35].[tblCatTiposDenuncias] ([IDTipoDenuncia])
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones] CHECK CONSTRAINT [FK_Norma35TblTipoDenunciasNotificaciones_Norma35TblCatTiposDenuncias_IDTipoDenuncia]
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblTipoDenunciasNotificaciones_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones] CHECK CONSTRAINT [FK_Norma35TblTipoDenunciasNotificaciones_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones]  WITH CHECK ADD  CONSTRAINT [Ck_Norma35TblTipoDenunciasNotificaciones_ValidarEmail] CHECK  (([EmailAsignado] IS NULL OR [EmailAsignado] like '%_@__%.__%'))
GO
ALTER TABLE [Norma35].[tblTipoDenunciasNotificaciones] CHECK CONSTRAINT [Ck_Norma35TblTipoDenunciasNotificaciones_ValidarEmail]
GO
