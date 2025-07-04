USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteRegPatronal](
	[IDClienteRegPatronal] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[RegPatronal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ActividadEconomica] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteLegal] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OcupacionRepLegal] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
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
 CONSTRAINT [PK_ProcomTblClienteRegPatronal_IDClienteRegPatronal] PRIMARY KEY CLUSTERED 
(
	[IDClienteRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteRegPatronal_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_RHTblCatClientes_ProcomTblClienteRegPatronal_IDCliente]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColinias_PROCOMtblClienteRegPatronal_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_SatTblCatColinias_PROCOMtblClienteRegPatronal_IDColonia]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColonias_PROCOMtblClienteRegPatronal_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_SatTblCatColonias_PROCOMtblClienteRegPatronal_IDCodigoPostal]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_PROCOMtblClienteRegPatronal_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_SatTblCatEstados_PROCOMtblClienteRegPatronal_IDEstado]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_PROCOMtblClienteRegPatronal_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_SatTblCatMunicipios_PROCOMtblClienteRegPatronal_IDMunicipio]
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_PROCOMtblClienteRegPatronal_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [PROCOM].[tblClienteRegPatronal] CHECK CONSTRAINT [FK_SatTblCatPaises_PROCOMtblClienteRegPatronal_IDPais]
GO
