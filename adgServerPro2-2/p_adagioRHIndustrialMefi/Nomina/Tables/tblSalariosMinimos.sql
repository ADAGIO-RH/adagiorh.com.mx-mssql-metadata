USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblSalariosMinimos](
	[IDSalarioMinimo] [int] IDENTITY(1,1) NOT NULL,
	[Fecha] [date] NOT NULL,
	[SalarioMinimo] [decimal](18, 2) NULL,
	[SalarioMinimoFronterizo] [decimal](18, 2) NULL,
	[UMA] [decimal](18, 2) NULL,
	[FactorDescuento] [decimal](18, 2) NULL,
	[IDPais] [int] NULL,
	[AjustarUMI] [bit] NULL,
	[TopeMensualSubsidioSalario] [decimal](18, 2) NULL,
	[PorcentajeUMASubsidio] [decimal](18, 2) NULL,
 CONSTRAINT [Pk_NominaTblSalariosMinimos_IDSalarioMinimo] PRIMARY KEY CLUSTERED 
(
	[IDSalarioMinimo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblSalariosMinimos_IDPais_Fecha] UNIQUE NONCLUSTERED 
(
	[IDPais] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblSalariosMinimos] ADD  CONSTRAINT [d_NominaTblSalariosMinimos_AjustarUMI]  DEFAULT ((0)) FOR [AjustarUMI]
GO
ALTER TABLE [Nomina].[tblSalariosMinimos]  WITH CHECK ADD  CONSTRAINT [FK_SATTblCatPaises_NominaTblSalariosMinimos_IDPais] FOREIGN KEY([IDPais])
REFERENCES [Sat].[tblCatPaises] ([IDPais])
GO
ALTER TABLE [Nomina].[tblSalariosMinimos] CHECK CONSTRAINT [FK_SATTblCatPaises_NominaTblSalariosMinimos_IDPais]
GO
