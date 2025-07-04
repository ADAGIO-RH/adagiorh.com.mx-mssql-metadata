USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblConfiguracionImpresorasTickets](
	[IDConfiguracionImpresoraTicket] [int] IDENTITY(1,1) NOT NULL,
	[NombreImpresora] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[TipoReferencia] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[IDSizePapelImpresionTickets] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_AppTblConfiguracionImpresorasTickets_IDConfiguracionImpresoraTicket] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionImpresoraTicket] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [App].[tblConfiguracionImpresorasTickets]  WITH CHECK ADD  CONSTRAINT [Fk_AppTblConfiguracionImpresorasTickets_AppTblCatSizePapelImpresionTickets_IDSizePapelImpresionTickets] FOREIGN KEY([IDSizePapelImpresionTickets])
REFERENCES [App].[tblCatSizePapelImpresionTickets] ([IDSizePapelImpresionTickets])
GO
ALTER TABLE [App].[tblConfiguracionImpresorasTickets] CHECK CONSTRAINT [Fk_AppTblConfiguracionImpresorasTickets_AppTblCatSizePapelImpresionTickets_IDSizePapelImpresionTickets]
GO
