USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatSucursales](
	[IDSucursal] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[CuentaContable] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Calle] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDColonia] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDEstado] [int] NULL,
	[IDPais] [int] NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Responsable] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Email] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[ClaveEstablecimiento] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstadoSTPS] [int] NULL,
	[IDMunicipioSTPS] [int] NULL,
	[Latitud] [float] NULL,
	[Longitud] [float] NULL,
	[Fronterizo] [bit] NULL,
 CONSTRAINT [PK_tblCatSucursales_IDSucursal] PRIMARY KEY CLUSTERED 
(
	[IDSucursal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatSucursales_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatSucursales] ADD  DEFAULT ((0)) FOR [Fronterizo]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_IDCodigoPostal_RHTblCatSucursales_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_IDCodigoPostal_RHTblCatSucursales_IDCodigoPostal]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColonias_IDColonia_RHTblCatSucursales_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_SatTblCatColonias_IDColonia_RHTblCatSucursales_IDColonia]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_IDEstado_RHTblCatSucursales_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_SatTblCatEstados_IDEstado_RHTblCatSucursales_IDEstado]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_IDMunicipio_RHTblCatSucursales_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_SatTblCatMunicipios_IDMunicipio_RHTblCatSucursales_IDMunicipio]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_IDPais_RHTblCatSucursales_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_SatTblCatPaises_IDPais_RHTblCatSucursales_IDPais]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_STPSTblCatEstados_RHTblCatSucursales_IDEstadoSTPS] FOREIGN KEY([IDEstadoSTPS])
REFERENCES [STPS].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_STPSTblCatEstados_RHTblCatSucursales_IDEstadoSTPS]
GO
ALTER TABLE [RH].[tblCatSucursales]  WITH CHECK ADD  CONSTRAINT [FK_STPSTblCatMunicipios_RHTblCatSucursales_IDMunicipioSTPS] FOREIGN KEY([IDMunicipioSTPS])
REFERENCES [STPS].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblCatSucursales] CHECK CONSTRAINT [FK_STPSTblCatMunicipios_RHTblCatSucursales_IDMunicipioSTPS]
GO
