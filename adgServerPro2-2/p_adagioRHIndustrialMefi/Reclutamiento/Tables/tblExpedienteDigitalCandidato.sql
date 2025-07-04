USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Reclutamiento].[tblExpedienteDigitalCandidato](
	[IDExpedienteDigitalCandidato] [int] IDENTITY(1,1) NOT NULL,
	[IDCandidato] [int] NOT NULL,
	[IDExpedienteDigital] [int] NOT NULL,
	[Name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ContentType] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[PathFile] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Size] [int] NULL,
	[FechaVencimiento] [datetime] NULL,
	[FechaCreacion] [datetime] NULL,
	[ArchivoMovido] [bit] NULL,
 CONSTRAINT [PK_ReclutamientoExpedienteDigitalCandidato_IDExpedienteDigitalCandidato] PRIMARY KEY CLUSTERED 
(
	[IDExpedienteDigitalCandidato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Reclutamiento].[tblExpedienteDigitalCandidato] ADD  DEFAULT ((0)) FOR [ArchivoMovido]
GO
ALTER TABLE [Reclutamiento].[tblExpedienteDigitalCandidato]  WITH CHECK ADD  CONSTRAINT [FK_ReclutamientoTblCandidatos_ReclutamientoExpedienteDigitalCandidato_IDCandidato] FOREIGN KEY([IDCandidato])
REFERENCES [Reclutamiento].[tblCandidatos] ([IDCandidato])
GO
ALTER TABLE [Reclutamiento].[tblExpedienteDigitalCandidato] CHECK CONSTRAINT [FK_ReclutamientoTblCandidatos_ReclutamientoExpedienteDigitalCandidato_IDCandidato]
GO
ALTER TABLE [Reclutamiento].[tblExpedienteDigitalCandidato]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatExpedientesDigitales_ReclutamientotblExpedienteDigitalCandidato_IDExpedienteDigital] FOREIGN KEY([IDExpedienteDigital])
REFERENCES [RH].[tblCatExpedientesDigitales] ([IDExpedienteDigital])
GO
ALTER TABLE [Reclutamiento].[tblExpedienteDigitalCandidato] CHECK CONSTRAINT [FK_RHtblCatExpedientesDigitales_ReclutamientotblExpedienteDigitalCandidato_IDExpedienteDigital]
GO
