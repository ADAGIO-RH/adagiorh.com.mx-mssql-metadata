USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblMovAfiliatorioBajaContrato](
	[IDMovAfiliatorioBajaContrato] [int] IDENTITY(1,1) NOT NULL,
	[IDMovAfiliatorio] [int] NOT NULL,
	[IDContratoEmpleado] [int] NOT NULL,
 CONSTRAINT [PK_RHtblMovAfiliatorioBajaContrato_IDMovAfiliatorioBajaContrato] PRIMARY KEY CLUSTERED 
(
	[IDMovAfiliatorioBajaContrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblMovAfiliatorioBajaContrato_IDContratoEmpleado] ON [RH].[tblMovAfiliatorioBajaContrato]
(
	[IDContratoEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblMovAfiliatorioBajaContrato_IDMovAfiliatorio] ON [RH].[tblMovAfiliatorioBajaContrato]
(
	[IDMovAfiliatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblMovAfiliatorioBajaContrato]  WITH CHECK ADD  CONSTRAINT [FK_IMSStblMovAfiliatorios_RHtblMovAfiliatorioBajaContrato_IDMovAfiliatorio] FOREIGN KEY([IDMovAfiliatorio])
REFERENCES [IMSS].[tblMovAfiliatorios] ([IDMovAfiliatorio])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblMovAfiliatorioBajaContrato] CHECK CONSTRAINT [FK_IMSStblMovAfiliatorios_RHtblMovAfiliatorioBajaContrato_IDMovAfiliatorio]
GO
ALTER TABLE [RH].[tblMovAfiliatorioBajaContrato]  WITH CHECK ADD  CONSTRAINT [FK_RHtblContratoEmpleado_RHtblMovAfiliatorioBajaContrato_IDContratoEmpleado] FOREIGN KEY([IDContratoEmpleado])
REFERENCES [RH].[tblContratoEmpleado] ([IDContratoEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[tblMovAfiliatorioBajaContrato] CHECK CONSTRAINT [FK_RHtblContratoEmpleado_RHtblMovAfiliatorioBajaContrato_IDContratoEmpleado]
GO
