USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FirmaDigital].[tblDocumentos](
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDTipoDocumento] [int] NOT NULL,
	[Nombre] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[State] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ExternalId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MessageForSigners] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RemindEvery] [int] NULL,
	[OriginalHash] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileName] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SignedByAll] [bit] NULL,
	[Signed] [bit] NULL,
	[SignedAt] [datetime] NULL,
	[DaysToExpire] [int] NULL,
	[ExpiresAt] [datetime] NULL,
	[CreatedAt] [datetime] NULL,
	[CallbackUrl] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SignCallbackUrl] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[File] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileDownload] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileSigned] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileSignedDownload] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FileZipped] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ManualClose] [bit] NULL,
	[SendMail] [bit] NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [PK_FirmaDigitalTblDocumentos_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] ADD  CONSTRAINT [d_FirmaDigitalTblDocumentos_SignedByAll]  DEFAULT ((0)) FOR [SignedByAll]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] ADD  CONSTRAINT [d_FirmaDigitalTblDocumentos_Signed]  DEFAULT ((0)) FOR [Signed]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] ADD  CONSTRAINT [d_FirmaDigitalTblDocumentos_ManualClose]  DEFAULT ((0)) FOR [ManualClose]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] ADD  CONSTRAINT [d_FirmaDigitalTblDocumentos_SendMail]  DEFAULT ((0)) FOR [SendMail]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_FirmaDigitalTblCatTiposDocumentos_IDTipoDocumento] FOREIGN KEY([IDTipoDocumento])
REFERENCES [FirmaDigital].[TblCatTiposDocumentos] ([IDTipoDocumento])
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] CHECK CONSTRAINT [FK_FirmaDigitalTblCatTiposDocumentos_IDTipoDocumento]
GO
ALTER TABLE [FirmaDigital].[tblDocumentos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_FirmaDigitaltblDocumentos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [FirmaDigital].[tblDocumentos] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_FirmaDigitaltblDocumentos_IDUsuario]
GO
