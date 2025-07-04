USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblCatDatosExtras](
	[IDDatoExtra] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoDatoExtra] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDInputType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaHoraReg] [datetime] NOT NULL,
 CONSTRAINT [Pk_AppTblCatDatosExtras_IDDatoExtra] PRIMARY KEY CLUSTERED 
(
	[IDDatoExtra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [App].[tblCatDatosExtras] ADD  CONSTRAINT [D_AppTblCatDatosExtras_FechaHoraReg]  DEFAULT (getdate()) FOR [FechaHoraReg]
GO
ALTER TABLE [App].[tblCatDatosExtras]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatDatosExtras_AppTblCatInputsTypes_IDInputType] FOREIGN KEY([IDInputType])
REFERENCES [App].[tblCatInputsTypes] ([IDInputType])
GO
ALTER TABLE [App].[tblCatDatosExtras] CHECK CONSTRAINT [Fk_AppTblCatDatosExtras_AppTblCatInputsTypes_IDInputType]
GO
ALTER TABLE [App].[tblCatDatosExtras]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatDatosExtras_AppTblCatTiposDatosExtras] FOREIGN KEY([IDTipoDatoExtra])
REFERENCES [App].[tblCatTiposDatosExtras] ([IDTipoDatoExtra])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblCatDatosExtras] CHECK CONSTRAINT [Fk_AppTblCatDatosExtras_AppTblCatTiposDatosExtras]
GO
ALTER TABLE [App].[tblCatDatosExtras]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblCatDatosExtras_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
ON DELETE CASCADE
GO
ALTER TABLE [App].[tblCatDatosExtras] CHECK CONSTRAINT [Fk_AppTblCatDatosExtras_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [App].[tblCatDatosExtras]  WITH CHECK ADD  CONSTRAINT [Chk_AppTblCatDatosExtras_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [App].[tblCatDatosExtras] CHECK CONSTRAINT [Chk_AppTblCatDatosExtras_Traduccion]
GO
