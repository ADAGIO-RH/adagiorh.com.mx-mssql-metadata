USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facturacion].[TblTimbrado](
	[IDTimbrado] [int] IDENTITY(1,1) NOT NULL,
	[IDHistorialEmpleadoPeriodo] [int] NOT NULL,
	[IDTipoRegimen] [int] NOT NULL,
	[UUID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ACUSE] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstatusTimbrado] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Actual] [bit] NULL,
	[IDUsuario] [int] NULL,
	[CodigoError] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Error] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SelloCFDI] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SelloSAT] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CadenaOriginal] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NoCertificadoSat] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CustomID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_FacturacionTblTimbrado_IDTimbrado] PRIMARY KEY CLUSTERED 
(
	[IDTimbrado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FacturaciontblTimbrado_IDEstatusTimbrado] ON [Facturacion].[TblTimbrado]
(
	[IDEstatusTimbrado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FacturaciontblTimbrado_IDHistorialEmpleadoPeriodo] ON [Facturacion].[TblTimbrado]
(
	[IDHistorialEmpleadoPeriodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FacturaciontblTimbrado_IDHistorialEmpleadoPeriodo_IDEstatusTImbrado] ON [Facturacion].[TblTimbrado]
(
	[IDHistorialEmpleadoPeriodo] ASC,
	[IDEstatusTimbrado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [Facturacion].[TblTimbrado] ADD  DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [Facturacion].[TblTimbrado] ADD  DEFAULT ((0)) FOR [Actual]
GO
ALTER TABLE [Facturacion].[TblTimbrado]  WITH CHECK ADD  CONSTRAINT [FK_FacturacionTblCatEstatusTimbrado_FacturacionTblTimbrado_IdEstatusTimbrado] FOREIGN KEY([IDEstatusTimbrado])
REFERENCES [Facturacion].[tblCatEstatusTimbrado] ([IDEstatusTimbrado])
GO
ALTER TABLE [Facturacion].[TblTimbrado] CHECK CONSTRAINT [FK_FacturacionTblCatEstatusTimbrado_FacturacionTblTimbrado_IdEstatusTimbrado]
GO
ALTER TABLE [Facturacion].[TblTimbrado]  WITH CHECK ADD  CONSTRAINT [FK_NominatblHistorialEmpleadoPeriodo_FacturacionTblTimbrado_IDHistorialEmpleadoPeriodo] FOREIGN KEY([IDHistorialEmpleadoPeriodo])
REFERENCES [Nomina].[tblHistorialesEmpleadosPeriodos] ([IDHistorialEmpleadoPeriodo])
GO
ALTER TABLE [Facturacion].[TblTimbrado] CHECK CONSTRAINT [FK_NominatblHistorialEmpleadoPeriodo_FacturacionTblTimbrado_IDHistorialEmpleadoPeriodo]
GO
ALTER TABLE [Facturacion].[TblTimbrado]  WITH CHECK ADD  CONSTRAINT [FK_SatTblCatTiposRegimen_FacturacionTblTimbrado_IDTipoRegimen] FOREIGN KEY([IDTipoRegimen])
REFERENCES [Sat].[tblCatTiposRegimen] ([IDTipoRegimen])
GO
ALTER TABLE [Facturacion].[TblTimbrado] CHECK CONSTRAINT [FK_SatTblCatTiposRegimen_FacturacionTblTimbrado_IDTipoRegimen]
GO
ALTER TABLE [Facturacion].[TblTimbrado]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_FacturacionTblTimbrado_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Facturacion].[TblTimbrado] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_FacturacionTblTimbrado_IDUsuario]
GO
