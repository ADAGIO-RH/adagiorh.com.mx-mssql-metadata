USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteDatosConstitutivos](
	[IDClienteDatosConstitutivos] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[RazonSocial] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumeroEscritura] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FolioMercantil] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaEscritura] [date] NULL,
	[IDCatTipoPoder] [int] NULL,
	[IDCatTipoEscritura] [int] NULL,
	[IDCatTipoFederativo] [int] NULL,
	[RepresentantePaterno] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteMaterno] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteNombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteRFC] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteCURP] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NotarioPaterno] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NotarioMaterno] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NotarioNombre] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[LugarEscrituracion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NumeroNotario] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Vigente] [bit] NULL,
 CONSTRAINT [PK_TblClienteDatosConstitutivos_IDClienteDatosConstitutivos] PRIMARY KEY CLUSTERED 
(
	[IDClienteDatosConstitutivos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] ADD  CONSTRAINT [d_ProcomtblClienteDatosConstitutivos_Vigente]  DEFAULT ((0)) FOR [Vigente]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatTipoEscritura_ProcomTbllienteDatosConstitutivos_IDCatTipoEscritura] FOREIGN KEY([IDCatTipoEscritura])
REFERENCES [PROCOM].[tblCatTipoEscritura] ([IDCatTipoEscritura])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_ProcomTblCatTipoEscritura_ProcomTbllienteDatosConstitutivos_IDCatTipoEscritura]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatTipoFederativo_ProcomTbllienteDatosConstitutivos_IDCatTipoFederativo] FOREIGN KEY([IDCatTipoFederativo])
REFERENCES [PROCOM].[tblCatTipoFederativo] ([IDCatTipoFederativo])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_ProcomTblCatTipoFederativo_ProcomTbllienteDatosConstitutivos_IDCatTipoFederativo]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatTipoPoder_ProcomTbllienteDatosConstitutivos_IDCatTipoPoder] FOREIGN KEY([IDCatTipoPoder])
REFERENCES [PROCOM].[tblcatTipoPoder] ([IDCatTipoPoder])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_ProcomTblCatTipoPoder_ProcomTbllienteDatosConstitutivos_IDCatTipoPoder]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteDatosConstitutivos_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteDatosConstitutivos_IDCliente]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_ProcomtblClienteDatosConstitutivos_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_SatTblCatEstados_ProcomtblClienteDatosConstitutivos_IDEstado]
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_ProcomtblClienteDatosConstitutivos_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [PROCOM].[tblClienteDatosConstitutivos] CHECK CONSTRAINT [FK_SatTblCatMunicipios_ProcomtblClienteDatosConstitutivos_IDMunicipio]
GO
