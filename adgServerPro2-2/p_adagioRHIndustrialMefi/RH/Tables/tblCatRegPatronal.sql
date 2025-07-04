USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatRegPatronal](
	[IDRegPatronal] [int] IDENTITY(1,1) NOT NULL,
	[RegistroPatronal] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ActividadEconomica] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConvenioSubsidios] [bit] NULL,
	[DelegacionIMSS] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SubDelegacionIMSS] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaAfiliacion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RepresentanteLegal] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OcupacionRepLegal] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDClaseRiesgo] [int] NULL,
 CONSTRAINT [PK_tblCatRegPatronal_IDRegPatronal] PRIMARY KEY CLUSTERED 
(
	[IDRegPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHtblCatRegPatronal_RegistroPatronal] UNIQUE NONCLUSTERED 
(
	[RegistroPatronal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblCatRegPatronal_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [RH].[tblCatRegPatronal] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblCatRegPatronal_IDCodigoPostal]
GO
ALTER TABLE [RH].[tblCatRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColinias_RHtblCatRegPatronal_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [RH].[tblCatRegPatronal] CHECK CONSTRAINT [FK_SatTblCatColinias_RHtblCatRegPatronal_IDColonia]
GO
ALTER TABLE [RH].[tblCatRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_RHtblCatRegPatronal_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblCatRegPatronal] CHECK CONSTRAINT [FK_SatTblCatEstados_RHtblCatRegPatronal_IDEstado]
GO
ALTER TABLE [RH].[tblCatRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_RHtblCatRegPatronal_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblCatRegPatronal] CHECK CONSTRAINT [FK_SatTblCatMunicipios_RHtblCatRegPatronal_IDMunicipio]
GO
ALTER TABLE [RH].[tblCatRegPatronal]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_RHtblCatRegPatronal_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblCatRegPatronal] CHECK CONSTRAINT [FK_SatTblCatPaises_RHtblCatRegPatronal_IDPais]
GO
