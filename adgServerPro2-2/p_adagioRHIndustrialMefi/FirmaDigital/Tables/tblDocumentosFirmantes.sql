USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [FirmaDigital].[tblDocumentosFirmantes](
	[IDFirmante] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Email] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TaxId] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Signed] [bit] NULL,
	[WidgetID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Current] [bit] NULL,
	[AllowedSignatureMethods] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_FirmaDigitalTblDocumentosFirmantes_IDFirmante] PRIMARY KEY CLUSTERED 
(
	[IDFirmante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [U_FirmaDigitaltblDocumentosFirmantes_ID_Email] ON [FirmaDigital].[tblDocumentosFirmantes]
(
	[ID] ASC,
	[Email] ASC
)
WHERE ([Email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [FirmaDigital].[tblDocumentosFirmantes]  WITH CHECK ADD  CONSTRAINT [FK_FirmaDigitalTblDocumentos_FirmaDigitalTblDocumentosFirmantes_ID] FOREIGN KEY([ID])
REFERENCES [FirmaDigital].[tblDocumentos] ([ID])
GO
ALTER TABLE [FirmaDigital].[tblDocumentosFirmantes] CHECK CONSTRAINT [FK_FirmaDigitalTblDocumentos_FirmaDigitalTblDocumentosFirmantes_ID]
GO
