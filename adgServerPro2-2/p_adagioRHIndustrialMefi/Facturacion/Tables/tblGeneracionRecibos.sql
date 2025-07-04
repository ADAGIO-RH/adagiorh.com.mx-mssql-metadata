USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Facturacion].[tblGeneracionRecibos](
	[IDReciboGeneracion] [int] IDENTITY(1,1) NOT NULL,
	[IDHistorialEmpleadoPeriodo] [int] NOT NULL,
	[Timbrado] [bit] NULL,
	[Generado] [bit] NULL,
	[Recibo] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[XML] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[QR] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaHoraCreacion] [datetime] NULL,
	[FechaHoraGeneracion] [datetime] NULL,
	[IDUsuario] [int] NOT NULL,
	[IDPeriodo] [int] NULL,
 CONSTRAINT [PK_FacturacionTblGeneracionRecibos_IDReciboGeneracion] PRIMARY KEY CLUSTERED 
(
	[IDReciboGeneracion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos] ADD  DEFAULT ((0)) FOR [Timbrado]
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos] ADD  DEFAULT ((0)) FOR [Generado]
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblCatPeriodos_FacturacionTblGeneracionRecibos_IDPeriodo] FOREIGN KEY([IDPeriodo])
REFERENCES [Nomina].[tblCatPeriodos] ([IDPeriodo])
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos] CHECK CONSTRAINT [FK_NominatblCatPeriodos_FacturacionTblGeneracionRecibos_IDPeriodo]
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos]  WITH CHECK ADD  CONSTRAINT [FK_NominatblHistorialesEmpleadosPeriodos_FacturacionTblGeneracionRecibos_IDHistorialEmpleadoPeriodo] FOREIGN KEY([IDHistorialEmpleadoPeriodo])
REFERENCES [Nomina].[tblHistorialesEmpleadosPeriodos] ([IDHistorialEmpleadoPeriodo])
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos] CHECK CONSTRAINT [FK_NominatblHistorialesEmpleadosPeriodos_FacturacionTblGeneracionRecibos_IDHistorialEmpleadoPeriodo]
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_FacturacionTblGeneracionRecibos_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Facturacion].[tblGeneracionRecibos] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_FacturacionTblGeneracionRecibos_IDUsuario]
GO
