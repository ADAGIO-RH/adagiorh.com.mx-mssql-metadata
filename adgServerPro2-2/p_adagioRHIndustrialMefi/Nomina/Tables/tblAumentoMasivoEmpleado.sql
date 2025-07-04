USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblAumentoMasivoEmpleado](
	[IDAumentoMasivoEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDAumentoMasivo] [int] NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[SalarioDiario] [decimal](18, 2) NULL,
	[SalarioIntegrado] [decimal](18, 2) NULL,
	[SalarioVariable] [decimal](18, 2) NULL,
	[SalarioDiarioReal] [decimal](18, 2) NULL,
	[IDRegPatronal] [int] NOT NULL,
	[IDMovAfiliatorio] [int] NULL,
 CONSTRAINT [Pk_NominatblAumentoMasivoEmpleado_IDAumentoMasivoEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDAumentoMasivoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado] ADD  CONSTRAINT [D_NominatblAumentoMasivoEmpleado_Excluir]  DEFAULT ((0)) FOR [IDMovAfiliatorio]
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_IMSStblMovAfiliatorios_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado] CHECK CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_IMSStblMovAfiliatorios_IDMovAfiliatorio]
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_NominatblAumentoMasivo_IDAumentoMasivo] FOREIGN KEY([IDAumentoMasivo])
REFERENCES [Nomina].[tblAumentoMasivo] ([IDAumentoMasivo])
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado] CHECK CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_NominatblAumentoMasivo_IDAumentoMasivo]
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_RHtblCatRegPatronal_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado] CHECK CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_RHtblCatRegPatronal_IDRegPatronal]
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [Nomina].[tblAumentoMasivoEmpleado] CHECK CONSTRAINT [Fk_NominatblAumentoMasivoEmpleado_RHTblEmpleados_IDEmpleado]
GO
