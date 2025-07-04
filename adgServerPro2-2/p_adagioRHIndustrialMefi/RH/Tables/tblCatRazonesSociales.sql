USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatRazonesSociales](
	[IDRazonSocial] [int] IDENTITY(1,1) NOT NULL,
	[RazonSocial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[IDOrigenRecurso] [int] NULL,
	[IDCliente] [int] NULL,
	[Comision] [decimal](18, 4) NULL,
 CONSTRAINT [PK_tblCatRazonesSociales_IDRazonSocial] PRIMARY KEY CLUSTERED 
(
	[IDRazonSocial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatClientes_RHtblCatRazonesSociales_IDCliente] FOREIGN KEY([IDCliente])
REFERENCES [RH].[tblCatClientes] ([IDCliente])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_RHTblCatClientes_RHtblCatRazonesSociales_IDCliente]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatRazonesSociales_SatTblCatRegimenesFiscales_IDRegimenFiscal] FOREIGN KEY([IDRegimenFiscal])
REFERENCES [Sat].[tblCatRegimenesFiscales] ([IDRegimenFiscal])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_RHtblCatRazonesSociales_SatTblCatRegimenesFiscales_IDRegimenFiscal]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblCatRazonesSociales_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblCatRazonesSociales_IDCodigoPostal]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColinias_RHtblCatRazonesSociales_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SatTblCatColinias_RHtblCatRazonesSociales_IDColonia]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_RHtblCatRazonesSociales_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SatTblCatEstados_RHtblCatRazonesSociales_IDEstado]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_RHtblCatRazonesSociales_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SatTblCatMunicipios_RHtblCatRazonesSociales_IDMunicipio]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatOrigenesRecursos_RHtblCatRazonesSociales_IDOrigenRecurso] FOREIGN KEY([IDOrigenRecurso])
REFERENCES [Sat].[tblCatOrigenesRecursos] ([IDOrigenRecurso])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SATTblCatOrigenesRecursos_RHtblCatRazonesSociales_IDOrigenRecurso]
GO
ALTER TABLE [RH].[tblCatRazonesSociales]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_RHtblCatRazonesSociales_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblCatRazonesSociales] CHECK CONSTRAINT [FK_SatTblCatPaises_RHtblCatRazonesSociales_IDPais]
GO
