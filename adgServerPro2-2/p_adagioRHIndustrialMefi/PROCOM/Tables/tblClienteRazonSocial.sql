USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteRazonSocial](
	[IDClienteRazonSocial] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[RFC] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CURP] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[IDOrigenRecursos] [int] NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CodigoPostal] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Municipio] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Localidad] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Colonia] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Pais] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_ProcomTblClienteRazonSocial_IDClienteRazonSocial] PRIMARY KEY CLUSTERED 
(
	[IDClienteRazonSocial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteRazonSocial_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteRazonSocial_IDCliente]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_ProcomTblClienteRazonSocial_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_ProcomTblClienteRazonSocial_IDCodigoPostal]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColonias_PROCOMtblClienteRazonSocial_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatColonias_PROCOMtblClienteRazonSocial_IDColonia]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_PROCOMtblClienteRazonSocial_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatEstados_PROCOMtblClienteRazonSocial_IDEstado]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_PROCOMtblClienteRazonSocial_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatMunicipios_PROCOMtblClienteRazonSocial_IDMunicipio]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SattblCatOrigenesRecursos_PROCOMtblClienteRazonSocial_IDOrigenRecursos] FOREIGN KEY([IDOrigenRecursos])
REFERENCES [Sat].[tblCatOrigenesRecursos] ([IDOrigenRecurso])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SattblCatOrigenesRecursos_PROCOMtblClienteRazonSocial_IDOrigenRecursos]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_PROCOMtblClienteRazonSocial_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatPaises_PROCOMtblClienteRazonSocial_IDPais]
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatRegimenesFiscales_PROCOMtblClienteRazonSocial_IDRegimenFiscal] FOREIGN KEY([IDRegimenFiscal])
REFERENCES [Sat].[tblCatRegimenesFiscales] ([IDRegimenFiscal])
GO
ALTER TABLE [PROCOM].[tblClienteRazonSocial] CHECK CONSTRAINT [FK_SatTblCatRegimenesFiscales_PROCOMtblClienteRazonSocial_IDRegimenFiscal]
GO
