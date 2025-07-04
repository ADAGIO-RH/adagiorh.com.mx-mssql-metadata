USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblEmpresa](
	[IdEmpresa] [int] IDENTITY(1,1) NOT NULL,
	[NombreComercial] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[RFC] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[IDCodigoPostal] [int] NULL,
	[IDEstado] [int] NULL,
	[IDMunicipio] [int] NULL,
	[IDColonia] [int] NULL,
	[IDPais] [int] NULL,
	[Calle] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Exterior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Interior] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegFonacot] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegInfonavit] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegSIEM] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RegEstatal] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRegimenFiscal] [int] NULL,
	[IDOrigenRecurso] [int] NULL,
	[PasswordInfonavit] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CURP] [varchar](18) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_tblEmpresa_IdEmpresa] PRIMARY KEY CLUSTERED 
(
	[IdEmpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_RHTblEmpresa_SatTblCatRegimenesFiscales_IDRegimenFiscal] FOREIGN KEY([IDRegimenFiscal])
REFERENCES [Sat].[tblCatRegimenesFiscales] ([IDRegimenFiscal])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_RHTblEmpresa_SatTblCatRegimenesFiscales_IDRegimenFiscal]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblEmpresa_IDCodigoPostal] FOREIGN KEY([IDCodigoPostal])
REFERENCES [Sat].[tblCatCodigosPostales] ([IDCodigoPostal])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SatTblCatCodigosPostales_RHtblEmpresa_IDCodigoPostal]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatColinias_RHtblEmpresa_IDColonia] FOREIGN KEY([IDColonia])
REFERENCES [Sat].[tblCatColonias] ([IDColonia])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SatTblCatColinias_RHtblEmpresa_IDColonia]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatEstados_RHtblEmpresa_IDEstado] FOREIGN KEY([IDEstado])
REFERENCES [Sat].[tblCatEstados] ([IDEstado])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SatTblCatEstados_RHtblEmpresa_IDEstado]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatMunicipios_RHtblEmpresa_IDMunicipio] FOREIGN KEY([IDMunicipio])
REFERENCES [Sat].[tblCatMunicipios] ([IDMunicipio])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SatTblCatMunicipios_RHtblEmpresa_IDMunicipio]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatOrigenesRecursos_RHTblEmpresa_IDOrigenRecurso] FOREIGN KEY([IDOrigenRecurso])
REFERENCES [Sat].[tblCatOrigenesRecursos] ([IDOrigenRecurso])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SATTblCatOrigenesRecursos_RHTblEmpresa_IDOrigenRecurso]
GO
ALTER TABLE [RH].[tblEmpresa]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatPaises_RHtblEmpresa_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [RH].[tblEmpresa] CHECK CONSTRAINT [FK_SatTblCatPaises_RHtblEmpresa_IDPais]
GO
